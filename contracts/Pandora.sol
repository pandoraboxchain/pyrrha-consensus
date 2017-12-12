pragma solidity ^0.4.18;

import './PAN.sol';
import './WorkerNode.sol';
import './Kernel.sol';
import './Dataset.sol';
import './factories/CognitiveJobFactory.sol';
import './factories/WorkerNodeFactory.sol';
import './lottery/LotteryEngine.sol';
import './lottery/RoundRobinLottery.sol';

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

contract Pandora is PAN, Ownable /* final */ {

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

    /// @notice Reference to a factory used in creating WorkerNode contracts
    /// @dev Reference to a factory used in creating WorkerNode contracts
    WorkerNodeFactory public workerNodeFactory;

    /// @notice List of registered worker nodes
    /// @dev List of registered worker nodes
    WorkerNode[] public workerNodes;

    /// @notice Index of registered worker nodes by their contract addresses mapping to their index in `workerNodes`.
    /// @dev Index of registered worker nodes by their contract addresses. Used for quick checks instead of
    /// gas-expensive search. Must have the same elements as `workerNodes`. Mapped +1 to the indexes of the contract in
    /// `workerNodes`; zero value is reserved for the removed or non-existing workers.
    /// At any point of time there must be less then 2^16 worker nodes.
    mapping(address => uint16) public workerAddresses;

    /// @dev List of active (=running) cognitive jobs mapped to their creators (owners of the corresponding
    /// cognitive job contracts)
    mapping(address => CognitiveJob) public activeJobs;

    /// ### Private and internal variables

    /// @dev Limit for the amount of lottery cycles before reporting failure to start cognitive job.
    /// Used in `createCognitiveJob`
    uint8 constant private MAX_WORKER_LOTTERY_TRIES = 10;

    /// @dev Since in the initial Pyrrha release of Pandora network reputation, verification and arbitration mechanics
    /// are under development it uses a set of pre-defined trusted addresses allowed to register worker nodes.
    /// These are specified during initial Pandora contract deployment by the founders.
    uint8 constant private WORKERNODE_WHITELIST_SIZE = 3;

    /// @dev Whitelist of node owners allowed to create nodes that perform cognitive work as a trusted environment
    /// for the first version of the protocol implementation codenamed Pyrrha
    address[] private workerNodeOwners;

    /// @dev Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    LotteryEngine internal workerLotteryEngine;

    /*******************************************************************************************************************
     * ## Events
     */

    /// @dev Event firing when a new cognitive job created
    event CognitiveJobCreated(CognitiveJob cognitiveJob);

    /// @dev Event firing when there is another worker node created
    event WorkerNodeCreated(WorkerNode workerNode);

    /// @dev Event firing when some worker node was destroyed
    event WorkerNodeDestroyed(WorkerNode workerNode);


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
    ) public {
        // Something is wrong with the compiler or Ethereum node if this check fails
        // (that's why its `assert`, not `require`)
        assert(_workerNodeOwners.length == WORKERNODE_WHITELIST_SIZE);

        // Must ensure that the supplied factories are already created contracts
        require(_jobFactory != address(0));
        require(_nodeFactory != address(0));

        // Assign factories to storage variables
        cognitiveJobFactory = _jobFactory;
        workerNodeFactory = _nodeFactory;

        // Iterate owners white list and add them to the contract storage
        for (uint8 no = 0; no < _workerNodeOwners.length && no < WORKERNODE_WHITELIST_SIZE; no++) {
            require(_workerNodeOwners[no] != address(0));
            workerNodeOwners.push(_workerNodeOwners[no]);
        }

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
    external
    onlyOwner
    onlyOnce('initialize') {
        // Checks that the factory contracts creator has assigned Pandora as an owner of the factory contracts:
        // an important security measure preventing "Parity-style" contract bugs
        require(workerNodeFactory.owner() == address(this));
        require(cognitiveJobFactory.owner() == address(this));

        properlyInitialized = true;
    }

    /*******************************************************************************************************************
     * ## Modifiers
     */

    /// @dev Modifier ensures that the function can be called only after Pandora contract was properly initialized
    /// (see `initialize` and `properlyInitialized`
    modifier onlyInitialized() {
        require(properlyInitialized == true);
        _;
    }

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

    /// @dev Checks that the function is called by the one of the nodes
    modifier onlyWorkerNodes() {
        require(workerAddresses[msg.sender] > 0);
        _;
    }

    /// @dev Checks that the function is called by the owner of one of the whitelisted nodes
    modifier onlyWhitelistedOwners() {
        bool found = false;
        for (uint8 no = 0; no < workerNodeOwners.length && no < WORKERNODE_WHITELIST_SIZE; no++) {
            // Worker node must not be destroyed and its owner must be the sender of the current function call
            if (workerNodeOwners[no] != address(0) &&
                msg.sender == workerNodeOwners[no]) {
                found = true;
                _;
                break;
            }
        }
        // Failing if ownership conditions are not satisfied
        require(found);
    }

    modifier checkWorkerAndOwner(
        WorkerNode _workerNode
    ) {
        address nodeOwner = msg.sender;
        require(nodeOwner == address(_workerNode.owner()));
        require(workerAddresses[nodeOwner] > 0);
        _;
    }

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

    /// @notice Returns count of registered worker nodes
    function workerNodesCount()
    public
    view
    returns (
    uint /// Count of registered worker nodes
    ) {
        return workerNodes.length;
    }

    /// @notice Creates, registers and returns a new worker node owned by the caller of the contract.
    /// Can be called only by the whitelisted node owner address.
    function createWorkerNode()
    external
    onlyInitialized
    onlyWhitelistedOwners
    returns (
        WorkerNode /// Address of the created worker node
    ) {
        address nodeOwner = msg.sender;
        /// @fixme This was a required for the sender to be an end address, not a proxy. Removed since prevents testing
        /// require(msg.sender == tx.origin);

        /// Check that we do not reach limits in the node count
        require(workerNodes.length < 2 ^ 16 - 1);

        /// @todo Check stake and bind it

        /// Creating worker node by using factory. See `properlyInitialized` comments for more details on factories
        WorkerNode workerNode = workerNodeFactory.create(nodeOwner);
        /// We do not check the created `workerNode` since all checks are done by the factory class
        workerNodes.push(workerNode);
        /// Saving index of the node in the `workerNodes` array (index + 1, zero is reserved for non-existing values)
        workerAddresses[address(workerNode)] = uint16(workerNodes.length);

        /// Firing event
        WorkerNodeCreated(workerNode);

        return workerNode;
    }

    /// @notice Defines possible cases for penaltize worker nodes. Used in `penaltizeWorker` function
    enum WorkersPenalties {
        OfflineWhileGathering,
        DeclinesJob,
        OfflineWhileDataValidation,
        FalseReportInvalidData,
        OfflineWhileCognition
    }

    function penaltizeWorkerNode(
        WorkerNode _guiltyWorker,
        WorkersPenalties _reason
    )
    external
    // @fixme Implement the modifier and uncomment
    onlyInitialized {
        /// Can be called only by the assigned cognitive job
        /// @todo Implement penalties from the bound worker node stakes
    }

    /// @notice Removes worker from the workers list and destroys it. Can be called only by the worker node owner
    /// and only for the idle workers
    function destroyWorkerNode(
        WorkerNode _workerNode
    )
    external
    checkWorkerAndOwner (_workerNode) /// Worker node can be destroyed only by its owner
    onlyInitialized {
        address nodeOwner = msg.sender;

        /// Can be called only  for the idle workers
        require(_workerNode.currentState() == _workerNode.Idle());

        /// Call worker node destroy function (can be triggered only by this Pandora contract). All balance
        /// is transferred to the node owner.
        /// We do this before removing worker node from the lists since we need to ensure that the node didn't
        /// got into non-idle state (self-destruct puts node into Destroyed state and it can't be assigned any
        /// tasks after that)
        _workerNode.destroy();

        /// Immediatelly removing node from the lists
        uint16 index = workerAddresses[nodeOwner] - 1;
        delete workerAddresses[nodeOwner];
        workerNodes[index] = workerNodes[workerNodes.length - 1];
        workerNodes.length--;

        /// @todo Return the unspent stake

        /// Firing the event
        WorkerNodeDestroyed(_workerNode);
    }

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
