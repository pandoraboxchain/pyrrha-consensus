pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../../lifecycle/Initializable.sol";
import "../lottery/RandomEngine.sol";
import "./ICognitiveJobManager.sol";
import "./WorkerNodeManager.sol";
import "../token/Reputation.sol";
import "./ICognitiveJobController.sol";

import {JobQueueLib as JQL} from "../../libraries/JobQueueLib.sol";

/**
 * @title Pandora Smart Contract
 * @author "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>
 *
 * @dev # Pandora Smart Contract
 *
 * Main & root contract implementing the first level of Pandora Boxchain consensus
 * See section ["3.3. Proof of Cognitive Work (PoCW)" in Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain)
 * for more details.
 */

contract CognitiveJobManager is ICognitiveJobManager, WorkerNodeManager {

    /*******************************************************************************************************************
     * ## Storage
     */

    /// ### Public variables

    /// @dev Contract, that store rep. values for each address
    IReputation public reputation;

    // Deposits from clients used as payment for work
    mapping(address => uint256) public deposits;

    /// @notice Status code returned by `createCognitiveJob()` method when no Idle WorkerNodes were available
    /// and job was not created but was put into the job queue to be processed lately
    uint8 constant public RESULT_CODE_ADD_TO_QUEUE = 0;
    /// @notice Status code returned by `createCognitiveJob()` method when CognitiveJob was created successfully
    uint8 constant public RESULT_CODE_JOB_CREATED = 1;

    uint256 constant public REQUIRED_DEPOSIT = 500 finney;

    /// ### Private and internal variables

    /// @dev Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    ILotteryEngine internal workerLotteryEngine;

    // Queue for CognitiveJobs kept while no Idle WorkerNodes available
    /// @dev Cognitive job queue used for case when no idle workers available
    using JQL for JQL.Queue;
    JQL.Queue internal jobQueue;

    // Controller for CognitiveJobs
    ICognitiveJobController public jobController;

    using SafeMath for uint;

    /*******************************************************************************************************************
     * ## Events
     */

    /// @dev Event firing when a new cognitive job created
    event CognitiveJobCreated(bytes32 jobId);

    /// @dev Event firing when a new cognitive job queued
    event CognitiveJobQueued(bytes32 jobId);

    /*******************************************************************************************************************
     * ## Constructor and initialization
     */

    /// ### Constructor
    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    constructor(
        ICognitiveJobController _jobController, /// Controller with all cognitive job logic and storage
        IWorkerNodeFactory _nodeFactory, /// Factory class for creating WorkerNode contracts
        IReputation _reputation
    )
    public
    WorkerNodeManager(_nodeFactory) {

        jobController = _jobController;
        // Init reputation storage contract
        reputation = _reputation;

        // Initializing worker lottery engine
        workerLotteryEngine = new RandomEngine();
    }

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public

    /// @notice Public function which checks queue of jobs and create new jobs
    /// #dev Function is called by worker owner, after finalize congitiveJob (but could be called by any address)
    /// to unlock worker's idle state and allocate newly freed WorkerNodes to perform cognitive jobs from the queue.
    function checkJobQueue(
    // No arguments
    )
    public {
        JQL.QueuedJob memory queuedJob;
        // Iterate queue and check queue depth

        uint8 limitQueueReq = uint8(jobQueue.queueDepth());
        limitQueueReq = limitQueueReq > 1 ? 1 : limitQueueReq;
        // todo check limit (2) for queue requests with tests

        for (uint8 k = 0; k < limitQueueReq; k++) {

            // Count remaining gas
            uint initialGas = gasleft();

            // Counting number of available worker nodes (in Idle state)
            uint256 estimatedSize = _countIdleWorkers();

            // There must be at least one free worker node
            if (estimatedSize <= 0) {
                break;
            }

            // Initializing in-memory array for idle node list and populating it with data
            IWorkerNode[] memory idleWorkers = _listIdleWorkers(estimatedSize);
            uint actualSize = idleWorkers.length;
            if (actualSize != estimatedSize) {
                break;
            }

            // Check number of batches with number of idle workers
            if (!jobQueue.checkElementBatches(actualSize)) {
                break;
            }

            // uint value1 = cognitiveJobQueue.queueDepth();
            uint256 value;
            // Value from queuedJob deposit
            (queuedJob, value) = jobQueue.requestJob();

            // Running lottery to select worker node to be assigned cognitive job contract
            IWorkerNode[] memory assignedWorkers = _selectWorkersWithLottery(idleWorkers, queuedJob.batches);

            bytes32 jobId = _initQueuedJob(queuedJob, assignedWorkers);

            emit CognitiveJobCreated(jobId);

            // Count used funds for queue
            //todo set limit for gasprice
            uint weiUsed = (57000 + initialGas - gasleft()) * tx.gasprice;
            //57k of gas used for transfers and storage writing

            weiUsed = weiUsed > value ? value : weiUsed;
            //weiUsed should not exceed deposit fixme set constraint to minimal deposit

            // Gas refund to node
            msg.sender.transfer(weiUsed);

            // Return remaining deposit to customer
            if (value - weiUsed != 0) {
                queuedJob.customer.transfer(value - weiUsed);
            }
        }
    }

    event Debug(address worker);

    /******************************************************************************************************************
    External functions
    */

    /// @notice Creates and returns new cognitive job contract and starts actual cognitive work instantly
    /// @dev Core function creating new cognitive job contract and returning it back to the caller
    function createCognitiveJob(
        IKernel _kernel, /// Pre-initialized kernel data entity contract
        IDataset _dataset, /// Pre-initialized dataset entity contract
        uint256 _complexity,
        bytes32 _description
    )
    external
    payable
    returns (
        bytes32 o_jobId, /// Newly created cognitive jobs (starts automatically)
        uint8 o_resultCode /// result code of creating job, 0 - job queued (no available workers) , 1 - job created
    ) {

        // Restriction for batches count came from potential high gas usage in JobQueue processing
        // todo check batches limit with tests
        uint8 batchesCount = _dataset.batchesCount();
        require(batchesCount <= 10);

        // Complexity should be divisible by workers
        require(_complexity >= uint256(batchesCount));

        // Dimensions of the input data and neural network input layer must be equal
        require(_kernel.dataDim() == _dataset.dataDim());

        // @todo check payment corresponds to required amount + gas payment - (fixed value + #batches * value)
        require(msg.value >= REQUIRED_DEPOSIT);

        // Counting number of available worker nodes (in Idle state)
        // Since Solidity does not supports dynamic in-memory arrays (yet), has to be done in two-staged way:
        // first by counting array size and then by allocating and populating array itself

        o_jobId = keccak256(abi.encodePacked(
                jobController.activeJobsCount() +
                jobController.completedJobsCount() +
                jobQueue.jobArray.length +
                block.number));
        uint256 estimatedSize = _countIdleWorkers();
        if (estimatedSize < uint256(batchesCount)) {
            // Put task in queue
            jobQueue.put(
                o_jobId,
                address(_kernel),
                address(_dataset),
                msg.sender,
                msg.value,
                batchesCount,
                _complexity,
                _description);
            //  Hold payment from customer
            deposits[msg.sender] = deposits[msg.sender].add(msg.value);
            o_resultCode = RESULT_CODE_ADD_TO_QUEUE;
            emit CognitiveJobQueued(o_jobId);
        } else {
            // Job created instantly
            // Return funds to sender
            msg.sender.transfer(msg.value);
            // Initializing in-memory array for idle node list and populating it with data
            IWorkerNode[] memory idleWorkers = _listIdleWorkers(estimatedSize);

            // Running lottery to select worker node to be assigned cognitive job contract
            IWorkerNode[] memory assignedWorkers = _selectWorkersWithLottery(idleWorkers, batchesCount);

            _initCognitiveJob(o_jobId, _kernel, _dataset, assignedWorkers, _complexity, _description);
            o_resultCode = RESULT_CODE_JOB_CREATED;

            emit CognitiveJobCreated(o_jobId);
        }
    }

    function getQueueDepth(
        // No arguments
    )
    external
    returns (uint256)
    {
        return jobQueue.queueDepth();
    }

    function provideResults(
        bytes32 _jobId,
        bytes _ipfsResults
    )
    external {
        //todo get workerId with workerController in new v.
        if (jobController.completeWork(_jobId, msg.sender, _ipfsResults)) {
            // Increase reputation of workers involved to computation
            //todo add koef for complexity-reputation
            uint256 complexity;
            address[] memory activeWorkers;
            ( , ,complexity, ,activeWorkers, , ) = jobController.getCognitiveJobDetails(_jobId);
            for (uint256 i = 0; i < activeWorkers.length; i++) {
                reputation.incrReputation(
                    activeWorkers[i],
                    complexity / activeWorkers.length);
            }
        }
    }

    function respondToJob(
        bytes32 _jobId,
        uint8 _responseType,
        bool _response)
    external {
        //todo implement get workerId with worker controller in new version
        jobController.respondToJob(_jobId, msg.sender, _responseType, _response);
    }

    function commitProgress(
        bytes32 _jobId,
        uint8 _percent)
    external {
        //todo implement get workerId with worker controller in new version
        jobController.commitProgress(_jobId, msg.sender, _percent);
    }

    /******************************************************************************************************************
    Private functions
    */

    function _initQueuedJob(JQL.QueuedJob queuedJob, IWorkerNode[] assignedWorkers)
    private
    onlyInitialized
    returns (
        bytes32
    ) {
        _initCognitiveJob(
            queuedJob.id,
            IKernel(queuedJob.kernel),
            IDataset(queuedJob.dataset),
            assignedWorkers,
            queuedJob.complexity,
            queuedJob.description
        );
        return queuedJob.id;
    }

    /// @notice Can"t be called by the user or other contract: for private use only
    /// @dev Creates cognitive job contract, saves it to storage and fires global event to notify selected worker node.
    /// Used both by `createCognitiveJob()` and `_checksJobQueue()` methods.
    function _initCognitiveJob(
        bytes32 _id,
        IKernel _kernel, /// Pre-initialized kernel data entity contract (taken from `createCognitiveJob` arguments or
    /// from the the `cognitiveJobQueue` `QueuedJob` structure)
        IDataset _dataset, /// Pre-initialized dataset entity contract (taken from `createCognitiveJob` arguments or
    /// from the the `cognitiveJobQueue` `QueuedJob` structure)
        IWorkerNode[] _assignedWorkers, /// Array of workers assigned for the job by the lottery engine //todo change to address
        uint256 _complexity,
        bytes32 _description
    )
    private
    onlyInitialized {

        // @fixme remove in upcoming version
        // (temporarily due to worker controller absence) convert workers array to address array
        address[] memory workerAddresses = new address[](_assignedWorkers.length);
        for (uint256 i = 0; i < workerAddresses.length; i++) {
            workerAddresses[i] = address(_assignedWorkers[i]);
        }

        jobController.createCognitiveJob(
            _id,
            address(_kernel),
            address(_dataset),
            workerAddresses,
            _complexity,
            _description);

        //assign each worker to job
        for (uint256 j = 0; j < _assignedWorkers.length; j++) {
            _assignedWorkers[j].assignJob(_id);
        }
    }

    /// @notice Can"t be called by the user or other contract: for private use only
    /// @dev Running lottery to select random worker nodes from the provided list. Used by both `createCognitiveJob`
    /// and `_checksJobQueue` functions.
    function _selectWorkersWithLottery(
        IWorkerNode[] _idleWorkers, /// Pre-defined pool of Idle WorkerNodes to select from
        uint _numberWorkersRequired /// Number of workers required by cognitive job, match with number of batches
    )
    private
    returns (
        IWorkerNode[] assignedWorkers /// Resulting sublist of the selected WorkerNodes
    ) {
        assignedWorkers = new IWorkerNode[](_numberWorkersRequired);
        uint no = workerLotteryEngine.getRandom(assignedWorkers.length);
        for (uint i = 0; i < assignedWorkers.length; i++) {
            assignedWorkers[i] = _idleWorkers[no];
            no = (no == assignedWorkers.length - 1) ? 0 : no + 1;
        }
    }

    /// @notice Can"t be called by the user or other contract: for private use only
    /// @dev Pre-count amount of available Idle WorkerNodes. Required to allocate in-memory list of WorkerNodes.
    function _countIdleWorkers(
    // No arguments
    )
    private
    view
    returns (
        uint o_estimatedSize /// Amount of currently available (Idle) WorkerNodes
    ) {
        o_estimatedSize = 0;
        for (uint i = 0; i < workerNodes.length; i++) {
            if (workerNodes[i].currentState() == workerNodes[i].Idle()) {
                o_estimatedSize++;
            }
        }
        return o_estimatedSize;
    }

    /// @notice Can"t be called by the user or other contract: for private use only
    /// @dev Allocates and returns in-memory array of all Idle WorkerNodes taking estimated size as an argument
    /// (returned by `_countIdleWorkers()`)
    function _listIdleWorkers(
        uint _estimatedSize /// Size of array to return
    )
    private
    view
    returns (
        IWorkerNode[] /// Returned array of all Idle WorkerNodes
    ) {
        IWorkerNode[] memory idleWorkers = new IWorkerNode[](_estimatedSize);
        uint256 actualSize = 0;
        for (uint j = 0; j < workerNodes.length; j++) {
            if (workerNodes[j].currentState() == workerNodes[j].Idle()) {
                idleWorkers[actualSize++] = workerNodes[j];
            }
        }
        return idleWorkers;
    }
}