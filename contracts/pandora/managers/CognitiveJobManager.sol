pragma solidity ^0.4.18;

import '../../lifecycle/Initializable.sol';
import '../lottery/RoundRobinLottery.sol';
import './ICognitiveJobManager.sol';
import './WorkerNodeManager.sol';
import '../../jobs/IComputingJob.sol';
import '../../libraries/JobQueueLib.sol';

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
    CognitiveJobFactory public cognitiveJobFactory;

    /// @dev Indexes (+1) of active (=running) cognitive jobs in `activeJobs` mapped from their creators
    /// (owners of the corresponding cognitive job contracts). Zero values corresponds to no active job,
    /// one – to the one with index 0 and so forth.
    mapping(address => uint16) public jobAddresses;

    /// @dev List of all active cognitive jobs
    IComputingJob[] public activeJobs;

    /// @dev Returns total count of active jobs
    function activeJobsCount() onlyInitialized view public returns (uint256) {
        return activeJobs.length;
    }

    /// @notice Status code returned by `createCognitiveJob()` method when no Idle WorkerNodes were available
    /// and job was not created but was put into the job queue to be processed lately
    uint8 constant public RESULT_CODE_ADD_TO_QUEUE = 0;
    /// @notice Status code returned by `createCognitiveJob()` method when CognitiveJob was created successfully
    uint8 constant public RESULT_CODE_JOB_CREATED = 1;

    /// ### Private and internal variables

    /// @dev Limit for the amount of lottery cycles before reporting failure to start cognitive job.
    /// Used in `createCognitiveJob`
    uint8 constant private MAX_WORKER_LOTTERY_TRIES = 10;

    /// @dev Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    ILotteryEngine internal workerLotteryEngine;

    // Queue for CognitiveJobs kept while no Idle WorkerNodes available
    using JobQueueLib for JobQueueLib.Queue;
    /// @dev Cognitive job queue used for case when no idle workers available
    JobQueueLib.Queue internal cognitiveJobQueue;

    /*******************************************************************************************************************
     * ## Events
     */

    /// @dev Event firing when a new cognitive job created
    event CognitiveJobCreated(IComputingJob cognitiveJob);


    /*******************************************************************************************************************
     * ## Constructor and initialization
     */

    /// ### Constructor
    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    function CognitiveJobManager (
        CognitiveJobFactory _jobFactory, /// Factory class for creating CognitiveJob contracts
        WorkerNodeFactory _nodeFactory /// Factory class for creating WorkerNode contracts
    )
    public
    WorkerNodeManager(_nodeFactory) {

        // Must ensure that the supplied factories are already created contracts
        require(_jobFactory != address(0));

        // Assign factories to storage variables
        cognitiveJobFactory = _jobFactory;

        // Initializing worker lottery engine
        // In Pyrrha we use round robin algorithm to give our whitelisted nodes equal and consequential chances
        workerLotteryEngine = new RoundRobinLottery();
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
        IComputingJob job = activeJobs[index];
        // Double-checking that the job at the index is the actual job being tested
        return(job == _job);
    }


    /// @notice Creates and returns new cognitive job contract and starts actual cognitive work instantly
    /// @dev Core function creating new cognitive job contract and returning it back to the caller
    function createCognitiveJob(
        IKernel kernel, /// Pre-initialized kernel data entity contract
        IDataset dataset /// Pre-initialized dataset entity contract
    )
    external
    payable
    onlyInitialized
    returns (
        IComputingJob o_cognitiveJob, /// Newly created cognitive jobs (starts automatically)
        uint8 o_resultCode /// result code of creating cognitiveJob, 0 - no available workers, 1 - job created
    ) {
        // Dimensions of the input data and neural network input layer must be equal
        require(kernel.dataDim() == dataset.dataDim());

        // The created job must fit into uint16 size
        require(activeJobs.length < 2 ^ 16 - 1);

        // Counting number of available worker nodes (in Idle state)
        // Since Solidity does not supports dynamic in-memory arrays (yet), has to be done in two-staged way:
        // first by counting array size and then by allocating and populating array itself
        uint256 estimatedSize = _countIdleWorkers();
        // There must be at least one free worker node
        if (estimatedSize <= 0) {
            o_resultCode = 0;
            o_cognitiveJob = IComputingJob(0);
            return (o_cognitiveJob, o_resultCode);
        }

        // Initializing in-memory array for idle node list and populating it with data
        IWorkerNode[] memory idleWorkers = _listIdleWorkers(estimatedSize);
        uint actualSize = idleWorkers.length;

        // Something really wrong happened with EVM if this assert fails
        if (actualSize != estimatedSize) {
            o_resultCode = 0;
            o_cognitiveJob = IComputingJob(0);
            return (o_cognitiveJob, o_resultCode);
        }

        /// @todo Add payments

        //Running lottery to select worker node to be assigned cognitive job contract
        IWorkerNode[] memory assignedWorkers = _selectWorkersWithLottery(idleWorkers);
        o_cognitiveJob = _initCognitiveJob(kernel, dataset, assignedWorkers);
        o_resultCode = RESULT_CODE_JOB_CREATED;
    }

    /// @notice Can't be called by the user, for internal use only
    /// @dev Function must be called only by the master node running cognitive job. It completes the job, updates
    /// worker node back to `Idle` state (in smart contract) and removes job contract from the list of active contracts
    function finishCognitiveJob(
        // No arguments - cognitive job is taken from msg.sender
    )
    external
    onlyInitialized {
        uint16 index = jobAddresses[msg.sender];
        require(index != 0);
        index--;

        IComputingJob job = activeJobs[index];
        require(address(job) == msg.sender);

        // @todo Kill the job contract

        for (uint no = 0; no < job.activeWorkersCount(); no++) {
            if (job.didWorkerCompute(no) == true) {
                job.activeWorkers(no).increaseReputation();
            }
        }

        // Remove cognitive job contract from the storage
        delete jobAddresses[address(job)];
        IComputingJob movedJob = activeJobs[index] = activeJobs[activeJobs.length - 1];
        jobAddresses[movedJob] = index + 1;
        activeJobs.length--;

        // After finish, try to start new CognitiveJob from a queue of activeJobs
        _checksJobQueue();
    }

    /// @notice Can't be called by the user or other contract: for private use only
    /// #dev Function is called only by `finishCognitiveJob()` in order to allocate newly freed WorkerNodes
    /// to perform cognitive jobs from the queue.
    function _checksJobQueue(
        // No arguments
    )
    private
    onlyInitialized {
        JobQueueLib.QueuedJob memory queuedJob;
        // Iterate queue and check queue depth
        for (uint256 k = 0; k < cognitiveJobQueue.queueDepth(); k++) {

            // Count remainig gas
            uint initialGas = msg.gas; // @fixme deprecated in 0.4.21. should be replaced with gasleft()

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
            if (!cognitiveJobQueue.compareFirstElementToIdleWorkers(actualSize)) {
                break;
            }

            uint256 value; // Value from queuedJob deposit
            (queuedJob, value) = cognitiveJobQueue.requestJob();

            // Running lottery to select worker node to be assigned cognitive job contract
            IWorkerNode[] memory assignedWorkers = _selectWorkersWithLottery(idleWorkers);

            _initCognitiveJob(queuedJob.kernel, queuedJob.dataset, assignedWorkers);

            // Count used funds for queue
            uint remainingGas = msg.gas;
            uint weiUsedForQueuedJob = (initialGas - remainingGas) / tx.gasprice;

            // Gas refund to node
            tx.origin.send(weiUsedForQueuedJob);

            /// @todo withdraw from client's global deposit
        }
    }

    /// @notice Can't be called by the user or other contract: for private use only
    /// @dev Creates cognitive job contract, saves it to storage and fires global event to notify selected worker node.
    /// Used both by `createCognitiveJob()` and `_checksJobQueue()` methods.
    function _initCognitiveJob(
        IKernel _kernel, /// Pre-initialized kernel data entity contract (taken from `createCognitiveJob` arguments or
                        /// from the the `cognitiveJobQueue` `QueuedJob` structure)
        IDataset _dataset, /// Pre-initialized dataset entity contract (taken from `createCognitiveJob` arguments or
                          /// from the the `cognitiveJobQueue` `QueuedJob` structure)
        IWorkerNode[] _assignedWorkers /// Array of workers assigned for the job by the lottery engine
    )
    private
    onlyInitialized
    returns (
        IComputingJob o_cognitiveJob /// Created cognitive job (function may fail only due to the bugs, so there is no
                                     /// reason for returning status code)
    ) {
        o_cognitiveJob = cognitiveJobFactory.create(_kernel, _dataset, _assignedWorkers);

        // Ensuring that contract was successfully created
        assert(o_cognitiveJob != address(0));
        // Hint: trying to figure out was the contract body actually created and initialized with proper values
        assert(o_cognitiveJob.Destroyed() == 0xFF);

        // Save new contract to the storage
        activeJobs.push(o_cognitiveJob);
        jobAddresses[o_cognitiveJob] = uint16(activeJobs.length);

        // Fire global event to notify the selected worker node
        CognitiveJobCreated(o_cognitiveJob);
        o_cognitiveJob.initialize();
    }

    /// @notice Can't be called by the user or other contract: for private use only
    /// @dev Running lottery to select random worker nodes from the provided list. Used by both `createCognitiveJob`
    /// and `_checksJobQueue` functions.
    function _selectWorkersWithLottery(
        IWorkerNode[] _idleWorkers /// Pre-defined pool of Idle WorkerNodes to select from
    )
    private
    returns (
        IWorkerNode[] /// Resulting sublist of the selected WorkerNodes
    ) {
        // @fixme Implement selection of more than one worker
        uint256 tryNo = 0;
        uint256 randomNo;
        IWorkerNode assignedWorker;
        do {
            assert(tryNo < MAX_WORKER_LOTTERY_TRIES);
            randomNo = workerLotteryEngine.getRandom(_idleWorkers.length);
            assignedWorker = _idleWorkers[randomNo];
            tryNo++;
        } while (assignedWorker.currentState() != assignedWorker.Idle());

        IWorkerNode[] memory assignedWorkers = new IWorkerNode[](1);
        assignedWorkers[0] = assignedWorker;
        return assignedWorkers;
    }

    /// @notice Can't be called by the user or other contract: for private use only
    /// @dev Pre-cound amount of available Idle WorkerNodes. Required to allocate in-memory list of WorkerNodes.
    function _countIdleWorkers(
        // No arguments
    )
    private
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

    /// @notice Can't be called by the user or other contract: for private use only
    /// @dev Allocates and returns in-memory array of all Idle WorkerNodes taking estimated size as an argument
    /// (returned by `_countIdleWorkers()`)
    function _listIdleWorkers(
        uint _estimatedSize /// Size of array to return
    )
    private
    returns (
        IWorkerNode[] /// Returned array of all Idle WorkerNodes
    ) {
        IWorkerNode[] memory idleWorkers = new IWorkerNode[](_estimatedSize);
        uint256 actualSize = 0;
        for (uint j = 0; j < workerNodes.length && j < _estimatedSize; j++) {
            if (workerNodes[j].currentState() == workerNodes[j].Idle()) {
                idleWorkers[actualSize++] = workerNodes[j];
            }
        }
        return idleWorkers;
    }
}
