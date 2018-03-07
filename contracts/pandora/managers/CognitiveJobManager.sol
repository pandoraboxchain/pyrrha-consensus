pragma solidity ^0.4.18;

import '../../lifecycle/Initializable.sol';
import '../lottery/RoundRobinLottery.sol';
import './ICognitiveJobManager.sol';
import './WorkerNodeManager.sol';
import '../../jobs/IComputingJob.sol';
import '../../libraries/CognitiveJobQueue.sol';

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

    uint8 constant public RESULT_CODE_ADD_TO_QUEUE = 0;
    uint8 constant public RESULT_CODE_JOB_CREATED = 1;

    /// ### Private and internal variables

    /// @dev Limit for the amount of lottery cycles before reporting failure to start cognitive job.
    /// Used in `createCognitiveJob`
    uint8 constant private MAX_WORKER_LOTTERY_TRIES = 10;

    /// @dev Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    ILotteryEngine internal workerLotteryEngine;

    ///@dev Cognitive job queue used for case when no idle workers available
    using CognitiveJobQueue for CognitiveJobQueue.Queue;
    CognitiveJobQueue.Queue internal cognitiveJobQueue;

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
        uint256 estimatedSize = countIdleWorkers();
        // There must be at least one free worker node
        if (estimatedSize <= 0) {
            o_resultCode = 0;
            o_cognitiveJob = IComputingJob(0);
            return (o_cognitiveJob, o_resultCode);
        }

        // Initializing in-memory array for idle node list and populating it with data
        IWorkerNode[] memory idleWorkers = createArrayIdleWorkers(estimatedSize);
        uint actualSize = idleWorkers.length;

        // Something really wrong happened with EVM if this assert fails
        if (actualSize != estimatedSize) {
            o_resultCode = 0;
            o_cognitiveJob = IComputingJob(0);
            return (o_cognitiveJob, o_resultCode);
        }

        /// @todo Add payments

        //Running lottery to select worker node to be assigned cognitive job contract
        IWorkerNode[] memory assignedWorkers = selectWorkerWithLottery(idleWorkers);
        initCognitiveJob(kernel, dataset, assignedWorkers);
        o_resultCode = RESULT_CODE_JOB_CREATED;
    }

    /**
     * @notice Can't be called by the user, for internal use only
     * @dev Function must be called only by the master node running cognitive job. It completes the job, updates
     * worker node back to `Idle` state (in smart contract) and removes job contract from the list of active contracts
     */
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
        createCognitiveJobFromQueue();
    }

    function createCognitiveJobFromQueue() private {
        CognitiveJobQueue.QueuedJob memory queuedJob;
        // Iterate queue and check queue depth
        for (uint256 k = 0; k < cognitiveJobQueue.queueDepth(); k++) {

            // Count remainig gas
            uint initialGas = msg.gas; //deprecated in 0.4.21. should be replaced with gasleft()

            // Counting number of available worker nodes (in Idle state)
            uint256 estimatedSize = countIdleWorkers();

            // There must be at least one free worker node
            if (estimatedSize <= 0) {
                break;
            }

            // Initializing in-memory array for idle node list and populating it with data
            IWorkerNode[] memory idleWorkers = createArrayIdleWorkers(estimatedSize);
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

            //Running lottery to select worker node to be assigned cognitive job contract
            IWorkerNode[] memory assignedWorkers = selectWorkerWithLottery(idleWorkers);

            initCognitiveJob(queuedJob.kernel, queuedJob.dataset, assignedWorkers);

            //Count used funds for queue
            uint remainingGas = msg.gas;
            uint weiUsedForQueuedJob = (initialGas - remainingGas) / tx.gasprice;

            // Gas refund to node
            refundToNode(weiUsedForQueuedJob);

            // TODO withdraw from client's global deposit
        }
    }

    ///@notice Create cognitive job contract, save it to storage and fire global event to notify selected worker node
    function initCognitiveJob(IKernel kernel, IDataset dataset, IWorkerNode[] assignedWorkers) private {

        IComputingJob o_cognitiveJob = cognitiveJobFactory.create(kernel, dataset, assignedWorkers);
            assert(o_cognitiveJob != address(0));
            // Save new contract to the storage
            activeJobs.push(o_cognitiveJob);
            jobAddresses[o_cognitiveJob] = uint16(activeJobs.length);

            // Fire global event to notify the selected worker node
            CognitiveJobCreated(o_cognitiveJob);
            o_cognitiveJob.initialize();
    }

    ///@notice Running lottery to select worker node
    function selectWorkerWithLottery(IWorkerNode[] idleWorkers) internal returns (IWorkerNode[]){
        uint256 tryNo = 0;
        uint256 randomNo;
        IWorkerNode assignedWorker;
        do {
            assert(tryNo < MAX_WORKER_LOTTERY_TRIES);
            randomNo = workerLotteryEngine.getRandom(idleWorkers.length);
            assignedWorker = idleWorkers[randomNo];
            tryNo++;
        } while (assignedWorker.currentState() != assignedWorker.Idle());

        IWorkerNode[] memory assignedWorkers = new IWorkerNode[](1);
        assignedWorkers[0] = assignedWorker;
        return assignedWorkers;
    }

    function refundToNode(uint amount) private {

        tx.origin.send(amount);
    }

    function countIdleWorkers() private returns(uint) {

        uint256 estimatedSize = 0;
        for (uint256 i = 0; i < workerNodes.length; i++) {
            if (workerNodes[i].currentState() == workerNodes[i].Idle()) {
                estimatedSize++;
            }
        }
        return estimatedSize;
    }

    function createArrayIdleWorkers(uint estimatedSize) private returns(IWorkerNode[]) {
        IWorkerNode[] memory idleWorkers = new IWorkerNode[](estimatedSize);
        uint256 actualSize = 0;
        for (uint j = 0; j < workerNodes.length; j++) {
            if (workerNodes[j].currentState() == workerNodes[j].Idle()) {
                idleWorkers[actualSize++] = workerNodes[j];
            }
        }
    }
}
