pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../../lifecycle/Initializable.sol";
import "../lottery/RandomEngine.sol";
import "./ICognitiveJobManager.sol";
import "./WorkerNodeManager.sol";
import "../../jobs/IComputingJob.sol";
import "../../libraries/JobQueueLib.sol";
import "../token/Reputation.sol";

/**
 * @title Pandora Smart Contract
 * @author "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>
 *
 * @dev # Pandora Smart Contract
 *
 * Main & root contract implementing the first level of Pandora Boxchain consensus
 * See section ["3.3. Proof of Cognitive Work (PoCW)" in Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain)
 * for more details.
 *
 * Contract token functionality is separated into a separate contract named PAN (after the name of the token)
 * and Pandora contracts just simply inherits PAN contract.
 */

contract CognitiveJobManager is Initializable, ICognitiveJobManager, WorkerNodeManager {

    /*******************************************************************************************************************
     * ## Storage
     */

    /// ### Public variables

    /// @notice Reference to a factory used in creating CognitiveJob contracts
    /// @dev Factories are used to reduce gas consumption by the main Pandora contract. Since Pandora needs to control
    /// the code used to deploy Cognitive Jobs and Worker Nodes, it must embed all the byte code for the smart contract.
    /// However this dramatically increases gas consumption for deploying Pandora contract itself. Thus, the
    /// CognitiveJob smart contract is deployed by a special factory class `CognitiveJobFactory`, and a special workflow
    /// is used to ensure uniqueness of the factories and the fact that their code source is coming from the same
    /// address which have deployed the main Pandora contract. In particular, because of this Pandora is defined as an
    /// `Ownable` contract and a special `initialize` function and `properlyInitialized` member variable is added.
    ICognitiveJobFactory public cognitiveJobFactory;

    /// @dev Indexes (+1) of active (=running) cognitive jobs in `activeJobs` mapped from their creators
    /// (owners of the corresponding cognitive job contracts). Zero values corresponds to no active job,
    /// one – to the one with index 0 and so forth.
    mapping(address => uint16) public jobAddresses;

    /// @dev List of all active cognitive jobs
    IComputingJob[] public cognitiveJobs;

    /// @dev Contract, that store rep. values for each address
    IReputation reputation;

    /// @dev Returns total count of active jobs
    function cognitiveJobsCount() onlyInitialized view public returns (uint256) {
        return cognitiveJobs.length;
    }

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
    using JobQueueLib for JobQueueLib.Queue;
    /// @dev Cognitive job queue used for case when no idle workers available
    JobQueueLib.Queue internal cognitiveJobQueue;

    using SafeMath for uint;

    /*******************************************************************************************************************
     * ## Events
     */

    /// @dev Event firing when a new cognitive job created
    event CognitiveJobCreated(IComputingJob cognitiveJob, uint resultCode);

    /// @dev Event firing when a new cognitive job failed to create
    event CognitiveJobCreateFailed(IComputingJob cognitiveJob, uint resultCode);

    /*******************************************************************************************************************
     * ## Constructor and initialization
     */

    /// ### Constructor
    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    constructor(
        ICognitiveJobFactory _jobFactory, /// Factory class for creating CognitiveJob contracts
        IWorkerNodeFactory _nodeFactory, /// Factory class for creating WorkerNode contracts
        IReputation _reputation
    )
    public
    WorkerNodeManager(_nodeFactory) {

        // Must ensure that the supplied factories are already created contracts
        require(_jobFactory != address(0));

        // Assign factories to storage variables
        cognitiveJobFactory = _jobFactory;

        reputation = _reputation;

        // Initializing worker lottery engine
        // In Pyrrha we use round robin algorithm to give our whitelisted nodes equal and consequential chances
        workerLotteryEngine = new RandomEngine();
    }

    /*******************************************************************************************************************
     * ## Modifiers
     */


    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

    /// @notice Test whether the given `job` is registered as an active job by the main Pandora contract
    /// @dev Used to test if some given job contract is a contract created by the Pandora and is listed by it as an
    /// active contract
    function isActiveJob(
        IComputingJob _job /// Job contract to test
    )
    onlyInitialized
    view
    public
    returns (
        bool /// Testing result
    ) {
        // Getting the index of the job from the internal list
        uint16 index = jobAddresses[_job];
        // Testing if the job was present in the list
        if (index == 0) {
            return false;
        }
        // We must decrease the index since they are 1-based, not 0-based (0 corresponds to "no contract" due to
        // Solidity specificity
        index--;

        // Retrieving the job contract from the index
        IComputingJob job = cognitiveJobs[index];
        // Double-checking that the job at the index is the actual job being tested
        return(job == _job);
    }

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
    onlyInitialized
    returns (
        IComputingJob o_cognitiveJob, /// Newly created cognitive jobs (starts automatically)
        uint8 o_resultCode /// result code of creating cognitiveJob, 0 - no available workers, 1 - job created
    ) {

        // Restriction for batches count came from potential high gas usage in JobQueue processing
        // todo check batches limit with tests
        uint8 batchesCount = _dataset.batchesCount();
        require(batchesCount <= 10);

        // Dimensions of the input data and neural network input layer must be equal
        require(_kernel.dataDim() == _dataset.dataDim());

        // The created job must fit into uint16 size
        require(uint256(cognitiveJobs.length) < 2 ** 16 - 1);

        // @todo check payment corresponds to required amount + gas payment - (fixed value + #batches * value)
        require(msg.value >= REQUIRED_DEPOSIT);

        // Counting number of available worker nodes (in Idle state)
        // Since Solidity does not supports dynamic in-memory arrays (yet), has to be done in two-staged way:
        // first by counting array size and then by allocating and populating array itself

        uint256 estimatedSize = _countIdleWorkers();
        // Put task in queue if number of idle workers less than number of batches in dataset
        if (estimatedSize < uint256(batchesCount)) {
            o_resultCode = RESULT_CODE_ADD_TO_QUEUE;
            cognitiveJobQueue.put(
                address(_kernel),
                address(_dataset),
                msg.sender,
                msg.value,
                batchesCount,
                _complexity,
                _description);
            emit CognitiveJobCreateFailed(o_cognitiveJob, o_resultCode);
            return (o_cognitiveJob, o_resultCode);
        }

        // Initializing in-memory array for idle node list and populating it with data
        IWorkerNode[] memory idleWorkers = _listIdleWorkers(estimatedSize);

        // Running lottery to select worker node to be assigned cognitive job contract
        IWorkerNode[] memory assignedWorkers = _selectWorkersWithLottery(idleWorkers, batchesCount);

        o_cognitiveJob = _initCognitiveJob(_kernel, _dataset, assignedWorkers, _complexity, _description);
        o_resultCode = RESULT_CODE_JOB_CREATED;

        //  Hold payment from customer
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);

        emit CognitiveJobCreated(o_cognitiveJob, o_resultCode);
    }

    //todo should be called after providing full result of entire job

    /// @notice Can"t be called by the user, for internal use only
    /// @dev Function must be called only by the master node running cognitive job. It completes the job, updates
    /// worker node back to `Idle` state (in smart contract) and removes job contract from the list of active contracts
    function finishCognitiveJob(
        // No arguments - cognitive job is taken from msg.sender
    )
    external
    onlyInitialized
    {
        uint16 index = jobAddresses[msg.sender];
        require(index != 0);
        index--;

        IComputingJob job = cognitiveJobs[index];
        require(address(job) == msg.sender);

        // @fixme set "Idle" state to the worker (check in stateMachine lib)

        // After finish, try to start new CognitiveJob from a queue of activeJobs
        _checkJobQueue();

        // Increase reputation of workers involved to computation
        uint256 reputationReward = job.complexity(); //todo add koef for complexity-reputation
        for (uint256 i = 0; i <= job.activeWorkersCount(); i++) {
            reputation.incrReputation(address(i), reputationReward);
        }
    }

    /// @notice Private function which checks queue of jobs and create new jobs
    /// #dev Function is called only in `finishCognitiveJob()` in order to allocate newly freed WorkerNodes
    /// to perform cognitive jobs from the queue.
    function _checkJobQueue(
        // No arguments
    )
    private
    onlyInitialized {
        JobQueueLib.QueuedJob memory queuedJob;
        // Iterate queue and check queue depth

        uint256 limitQueueReq = cognitiveJobQueue.queueDepth();
        limitQueueReq = limitQueueReq > 10 ? 10 : limitQueueReq; // todo check limit (10) for queue requests with tests

        for (uint256 k = 0; k < limitQueueReq; k++) {

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
            if (!cognitiveJobQueue.checkElementBatches(actualSize)) {
                break;
            }

            // uint value1 = cognitiveJobQueue.queueDepth();
            uint256 value; // Value from queuedJob deposit
            (queuedJob, value) = cognitiveJobQueue.requestJob();

            // Running lottery to select worker node to be assigned cognitive job contract
            IWorkerNode[] memory assignedWorkers = _selectWorkersWithLottery(idleWorkers, queuedJob.batches);

            IComputingJob createdCognitiveJob = _initQueuedJob(queuedJob, assignedWorkers);

            emit CognitiveJobCreated(createdCognitiveJob, RESULT_CODE_JOB_CREATED);

            // Count used funds for queue
            //todo set limit for gasprice
            uint weiUsed = (57000 + initialGas - gasleft()) * tx.gasprice; //57k of gas used for transfers and storage writing
            if (weiUsed > value) {
                weiUsed = value;
            }

//            emit DebugEvent(tx.gasprice);
//            emit DebugEvent(initialGas);
//            emit DebugEvent(gasleft());
//            emit DebugEvent(REQUIRED_DEPOSIT);
//            emit DebugEvent(weiUsed);
//            emit DebugEvent(this.balance);
//            emit DebugEvent(deposits[queuedJob.customer]);
//            emit DebugEvent(value - weiUsed);

	        //Withdraw from customer's deposit
            deposits[queuedJob.customer] = deposits[queuedJob.customer].sub(value);

            // Gas refund to node
            tx.origin.transfer(weiUsed);

            // Return remaining deposit to customer
            if (value - weiUsed != 0) {
                queuedJob.customer.transfer(value - weiUsed);
            }
        }
    }

    function _initQueuedJob(JobQueueLib.QueuedJob queuedJob, IWorkerNode[] assignedWorkers)
    private
    onlyInitialized
    returns (
        IComputingJob job
    ) {
        job = _initCognitiveJob(
            IKernel(queuedJob.kernel),
            IDataset(queuedJob.dataset),
            assignedWorkers,
            queuedJob.complexity,
            queuedJob.description
        );
    }

    event DebugEvent(uint value);
    event DebugEvent1(address addr);
    event DebugEvent2(IWorkerNode[] nodes);
    event DebugEvent3(bytes32 descr);

    /// @notice Can"t be called by the user or other contract: for private use only
    /// @dev Creates cognitive job contract, saves it to storage and fires global event to notify selected worker node.
    /// Used both by `createCognitiveJob()` and `_checksJobQueue()` methods.
    function _initCognitiveJob(
        IKernel _kernel, /// Pre-initialized kernel data entity contract (taken from `createCognitiveJob` arguments or
                        /// from the the `cognitiveJobQueue` `QueuedJob` structure)
        IDataset _dataset, /// Pre-initialized dataset entity contract (taken from `createCognitiveJob` arguments or
                          /// from the the `cognitiveJobQueue` `QueuedJob` structure)
        IWorkerNode[] _assignedWorkers, /// Array of workers assigned for the job by the lottery engine
        uint256 _complexity,
        bytes32 _description
    )
    private
    onlyInitialized
    returns (
        IComputingJob o_cognitiveJob /// Created cognitive job (function may fail only due to the bugs, so there is no
                                     /// reason for returning status code)
    ) {
        o_cognitiveJob = cognitiveJobFactory.create(_kernel, _dataset, _assignedWorkers, _complexity, _description);
//
        // Ensuring that contract was successfully created
        assert(o_cognitiveJob != address(0));
        // Hint: trying to figure out was the contract body actually created and initialized with proper values
        assert(o_cognitiveJob.currentState() == o_cognitiveJob.Uninitialized());

        // Save new contract to the storage
        cognitiveJobs.push(o_cognitiveJob);
        jobAddresses[o_cognitiveJob] = uint16(cognitiveJobs.length);

        o_cognitiveJob.initialize();
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