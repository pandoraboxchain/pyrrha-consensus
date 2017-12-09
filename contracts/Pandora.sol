pragma solidity ^0.4.15;

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

contract Pandora is PAN /* final */ {

    /**
     * ## Storage
     */

    enum WorkersPenalties {
        OfflineWhileGathering,
        DeclinesJob,
        OfflineWhileDataValidation,
        FalseReportInvalidData,
        OfflineWhileCognition
    }

    uint256 constant private MAX_WORKER_LOTTERY_TRIES = 10;

    uint8 constant private WORKERNODE_WHITELIST_SIZE = 3;

    CognitiveJobFactory cognitiveJobFactory;
    WorkerNodeFactory workerNodeFactory;

    /// @dev Whitelist of node owners allowed to create nodes that perform cognitive work as a trusted environment
    /// for the first version of the protocol implementation codenamed Pyrrha
    address[] private workerNodeOwners;
    WorkerNode[] public workerNodes;

    function workerNodesCount() external constant /* view */ returns (uint) {
        return workerNodes.length;
    }

    /// @dev List of active (=running) cognitive jobs mapped to their creators (owners of the corresponding
    /// cognitive job contracts)
    mapping(address => CognitiveJob) public activeJobs;

    /// @dev Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    LotteryEngine /* internal */ public workerLotteryEngine;

    /**
     * ## Events
     */

    /// @dev Event firing when a new cognitive job created
    event CognitiveJobCreated(CognitiveJob cognitiveJob);

    /// @dev Event firing when there is another worker node created
    event WorkerNodeCreated(WorkerNode workerNode);

    /**
     * ## Constructor
     */

    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    function Pandora (
        CognitiveJobFactory _jobFactory, /// Factory class for creating CognitiveJob contracts
        WorkerNodeFactory _nodeFactory, /// Factory class for creating WorkerNode contracts
        // Constant literal for array size in function arguments not working yet
        address[3 /* WORKERNODE_WHITELIST_SIZE */] _workerNodeOwners /// Worker node owners to be whitelisted by the contract
    ) {
        require(_jobFactory != address(0));
        require(_nodeFactory != address(0));

        // Something is wrong with the compiler or Ethereum node if this check fails
        // (that's why its `assert`, not `require`)
        assert(_workerNodeOwners.length == WORKERNODE_WHITELIST_SIZE);

        cognitiveJobFactory = _jobFactory;
        workerNodeFactory = _nodeFactory;

        for (uint8 no = 0; no < WORKERNODE_WHITELIST_SIZE; no++) {
            require(_workerNodeOwners[no] != address(0));
            workerNodeOwners.push(_workerNodeOwners[no]);
        }

        // Initializing worker lottery engine
        // In Pyrrha we use round robin algorithm to give our whitelisted nodes equal and consequential chances
        workerLotteryEngine = new RoundRobinLottery();
    }

    /**
     * ## Modifiers
     */

    /// @dev Checks that the function is called by the one of the nodes
    modifier onlyWorkerNodes() {
        bool found = false;
        for (uint256 no = 0; no < workerNodes.length; no++) {
            // Worker node must not be destroyed and its owner must be the sender of the current function call
            if (workerNodes[no].Destroyed() != 0 &&
                msg.sender == workerNodes[no].owner()) {
                found = true;
                _;
                break;
            }
        }
        // Failing if ownership conditions are not satisfied
        require(found);
    }

    /// @dev Checks that the function is called by the owner of one of the whitelisted nodes
    modifier onlyWhitelistedOwners() {
        bool found = false;
        for (uint256 no = 0; no < workerNodeOwners.length; no++) {
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

    /**
     * ## Functions
     */

    function createWorkerNode(
    ) external
        onlyWhitelistedOwners
    returns (
        WorkerNode
    ) {
        address nodeOwner = msg.sender;
        require(msg.sender == tx.origin);

        /// @todo Check stake and bind it

        WorkerNode workerNode = new WorkerNode(this);
        assert(workerNode != WorkerNode(0));

        workerNode.transferOwnership(nodeOwner);
        workerNodes.push(workerNode);

        WorkerNodeCreated(workerNode);
        return workerNode;
    }

    function penaltizeWorker(
        WorkerNode _guiltyWorker,
        WorkersPenalties _reason
    ) external {
        /// @todo implement
    }

    /// @notice Creates and returns new cognitive job contract and starts actual cognitive work instantly
    /// @dev Core function creating new cognitive job contract and returning it back to the caller
    function createCognitiveJob(
        Kernel kernel, /// Pre-initialized kernel data entity contract
        Dataset dataset /// Pre-initialized dataset entity contract
    ) external payable returns (
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
    ) external {
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
