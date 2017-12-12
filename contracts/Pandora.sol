pragma solidity ^0.4.18;

import './PAN.sol';
import './WorkerNode.sol';
import './Kernel.sol';
import './Dataset.sol';
import './factories/CognitiveJobFactory.sol';
import './factories/WorkerNodeFactory.sol';
import './lottery/LotteryEngine.sol';
import './lottery/RoundRobinLottery.sol';
import './pandora/WorkerNodeManager.sol';

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

contract Pandora is PAN, Ownable, WorkerNodeManager /* final */ {

    /*******************************************************************************************************************
     * ## Storage
     */

    /// ### Public variables

    /// @notice Indicates that Pandora contract was completely deployed and initialized with all necessary contract
    /// factories coming from the verified origin.
    /// @dev Factories are used to reduce gas consumption by the main Pandora contract. Since Pandora needs to control
    /// the code used to deploy Cognitive Jobs and Worker Nodes, it must embed all the byte code for the smart contract.
    /// However this dramatically increases gas consumption for deploying Pandora contract itself. Thus, the
    /// CognitiveJob smart contract is deployed by a special factory class `CognitiveJobFactory`, and a special workflow
    /// is used to ensure uniqueness of the factories and the fact that their code source is coming from the same
    /// address which have deployed the main Pandora contract. In particular, because of this Pandora is defined as an
    /// `Ownable` contract and a special `initialize` function and `properlyInitialized` member variable is added.
    bool public properlyInitialized = false;

    /// @notice Reference to a factory used in creating CognitiveJob contracts
    /// @dev Reference to a factory used in creating CognitiveJob contracts
    CognitiveJobFactory public cognitiveJobFactory;

    /// @dev List of active (=running) cognitive jobs mapped to their creators (owners of the corresponding
    /// cognitive job contracts)
    mapping(address => CognitiveJob) public activeJobs;

    /// ### Private and internal variables

    /// @dev Limit for the amount of lottery cycles before reporting failure to start cognitive job.
    /// Used in `createCognitiveJob`
    uint8 constant private MAX_WORKER_LOTTERY_TRIES = 10;

    /// @dev Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    LotteryEngine internal workerLotteryEngine;

    /*******************************************************************************************************************
     * ## Events
     */

    /// @dev Event firing when a new cognitive job created
    event CognitiveJobCreated(CognitiveJob cognitiveJob);


    /*******************************************************************************************************************
     * ## Constructor and initialization
     */

    /// ### Constructor
    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    function Pandora (
        CognitiveJobFactory _jobFactory, /// Factory class for creating CognitiveJob contracts
        WorkerNodeFactory _nodeFactory, /// Factory class for creating WorkerNode contracts
        // Constant literal for array size in function arguments not working yet
        address[3/*=WORKERNODE_WHITELIST_SIZE*/]
            _workerNodeOwners /// Worker node owners to be whitelisted by the contract
    )
    public
    WorkerNodeManager(_nodeFactory, _workerNodeOwners) {

        // Must ensure that the supplied factories are already created contracts
        require(_jobFactory != address(0));

        // Assign factories to storage variables
        cognitiveJobFactory = _jobFactory;

        // Initializing worker lottery engine
        // In Pyrrha we use round robin algorithm to give our whitelisted nodes equal and consequential chances
        workerLotteryEngine = new RoundRobinLottery();

        // Ensure that the contract is still uninitialized and `initialize` function be called to check the proper
        // setup of class factories
        properlyInitialized = false;
    }

    /// ### Initialization
    /// @notice Function that checks the proper setup of class factories. May be called only once and only by Pandora
    /// contract owner.
    /// @dev Function that checks the proper setup of class factories. May be called only once and only by Pandora
    /// contract owner.
    function initialize()
    public
    onlyOwner
    onlyOnce('initialize') {
        // Checks that the factory contracts creator has assigned Pandora as an owner of the factory contracts:
        // an important security measure preventing "Parity-style" contract bugs
        require(workerNodeFactory.owner() == address(this));
        require(cognitiveJobFactory.owner() == address(this));

        Initializable.initialize();
    }

    /*******************************************************************************************************************
     * ## Modifiers
     */

    /// @dev Internal private mapping storing flags indicating which of `onlyOnce` functions was already called.
    mapping(string => bool) private onceFlags;
    /// @dev Ensures that function with the modifier can be called only once during the whole contract lifecycle
    modifier onlyOnce(
        string _id /// Some id used to uniquely identify the caller function (usually the function name as a string)
    ) {
        require(onceFlags[_id] == false);
        _;
        onceFlags[_id] = true;
    }

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

    /// @notice Creates and returns new cognitive job contract and starts actual cognitive work instantly
    /// @dev Core function creating new cognitive job contract and returning it back to the caller
    function createCognitiveJob(
        Kernel kernel, /// Pre-initialized kernel data entity contract
        Dataset dataset /// Pre-initialized dataset entity contract
    )
    external
    payable
    onlyInitialized
    returns (
        CognitiveJob o_cognitiveJob /// Newly created cognitive jobs (starts automatically)
    ) {
        // Dimensions of the input data and neural network input layer must be equal
        require(kernel.dataDim() == dataset.dataDim());

        // Counting number of available worker nodes (in Idle state)
        // Since Solidity does not supports dynamic in-memory arrays (yet), has to be done in two-staged way:
        // first by counting array size and then by allocating and populating array itself
        uint256 estimatedSize = 0;
        for (uint256 no = 0; no < workerNodes.length; no++) {
            if (workerNodes[no].currentState() == workerNodes[no].Idle()) {
                estimatedSize++;
            }
        }
        // There must be at least one free worker node
        assert(estimatedSize > 0);

        // Initializing in-memory array for idle node list and populating it with data
        WorkerNode[] memory idleWorkers = new WorkerNode[](estimatedSize);
        uint256 actualSize = 0;
        for (no = 0; no < workerNodes.length; no++) {
            if (workerNodes[no].currentState() == workerNodes[no].Idle()) {
                idleWorkers[actualSize++] = workerNodes[no];
            }
        }
        // Something really wrong happened with EVM if this assert fails
        assert(actualSize == estimatedSize);

        /// @todo Add payments

        // Running lottery to select worker node to be assigned cognitive job contract
        uint256 tryNo = 0;
        uint256 randomNo;
        WorkerNode assignedWorker;
        do {
            assert(tryNo < MAX_WORKER_LOTTERY_TRIES);
            randomNo = workerLotteryEngine.getRandom(idleWorkers.length);
            assignedWorker = idleWorkers[randomNo];
            tryNo++;
        } while (assignedWorker.currentState() != assignedWorker.Idle());

        WorkerNode[] memory assignedWorkers = new WorkerNode[](1);
        assignedWorkers[0] = assignedWorker;
        // Create cognitive job contract
        o_cognitiveJob = cognitiveJobFactory.create(this, kernel, dataset, assignedWorkers);
        assert(o_cognitiveJob != address(0));
        // Save new contract to the storage
        activeJobs[address(o_cognitiveJob)] = o_cognitiveJob;

        // Fire global event to notify the selected worker node
        CognitiveJobCreated(o_cognitiveJob);
        o_cognitiveJob.initialize();
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
        CognitiveJob job = activeJobs[msg.sender];
        require(address(job) == msg.sender);

        for (uint no = 0; no < job.activeWorkersCount(); no++) {
            if (job.workerDidCompute(no) == true) {
                job.activeWorkers(no).increaseReputation();
            }
        }

        // Remove cognitive job contract from the storage
        delete activeJobs[msg.sender];
    }
}
