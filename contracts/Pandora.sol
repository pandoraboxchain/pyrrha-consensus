pragma solidity ^0.4.15;

import './PAN.sol';
import './WorkerNode.sol';
import './Kernel.sol';
import './Dataset.sol';
import './CognitiveJob.sol';
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

    uint256 constant private MAX_WORKER_LOTTERY_TRIES = 10;

    uint8 constant private WORKERNODE_WHITELIST_SIZE = 7;

    // Constant literal for array size is not working yet
    /// @dev Whitelist of nodes allowed to perform cognitive work as a trusted environment for the first version of
    /// the protocol implementation codenamed Pyrrha
    WorkerNode[7 /* WORKERNODE_WHITELIST_SIZE */] public workerNodes;

    /// @dev List of active (=running) cognitive jobs mapped to their creators (owners of the corresponding
    /// cognitive job contracts)
    mapping(address => CognitiveJob) public activeJobs;

    /// @dev Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    LotteryEngine internal workerLotteryEngine;

    /**
     * ## Events
     */

    /// @dev Event firing when a new cognitive job created
    event CognitiveJobCreated(CognitiveJob cognitiveJob);

    /**
     * ## Constructor
     */

    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    function Pandora (
        // Constant literal for array size in function arguments not working yet
        address[7 /* WORKERNODE_WHITELIST_SIZE */] _workerNodeOwners /// Worker node owners to be whitelisted by the contract
    ) {
        // Something is wrong with the compiler or Ethereum node if this check fails
        // (that's why its `assert`, not `require`)
        assert(_workerNodeOwners.length == workerNodes.length);

        for (uint8 no = 0; no < WORKERNODE_WHITELIST_SIZE; no++) {
            /// @todo Stakes thing

            // Creating new worker node contract for each of the seven pre-defined owners whitelisted at the moment
            // of creation of the main Pandora contract
            WorkerNode worker = new WorkerNode(this);

            // Change ownership of the worker node contract to a pre-defined owner passed to the constructor
            worker.transferOwnership(_workerNodeOwners[no]);

            // Store newly created worker node contract
            workerNodes[no] = worker;
        }

        // Initializing worker lottery engine
        // In Pyrrha we use round robin algorithm to give our whitelisted nodes equal and consequential chances
        workerLotteryEngine = new RoundRobinLottery();
    }

    /**
     * ## Modifiers
     */

    /// @dev Checks that the function is called by the owner of one of the whitelisted nodes
    modifier onlyWhitelistedNodes() {
        bool found = false;
        for (uint256 no = 0; no < workerNodes.length; no++) {
            // Worker node must not be destroyed and its owner must be the sender of the current function call
            if (workerNodes[no].currentState() != workerNodes[no].Destroyed() &&
                msg.sender == workerNodes[no].owner()) {
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

    /// @notice Can only be used by one of existing whitelisted worker node in case the other whitelisted node
    /// got somehow destroyed
    /// @dev Replaces one of occasionally destroyed worker nodes and replaces it with the other one. Can be called
    /// by the owner of one of existing worker nodes
    function replaceDestroyedWorker (
        /// Destroyed worker node contract (must be whitelisted before)
        WorkerNode _destroyedWorker,
        /// Replacement worker node contract, which will become whitelisted.
        /// Must be in Ilde state and not whitelisted before
        WorkerNode _replacedWorker
    ) external
        // Checking that only one of existing worker nodes calls this function
        onlyWhitelistedNodes
    {
        // Checking that the node is really destroyed
        require(_destroyedWorker.currentState() == _destroyedWorker.Destroyed());
        // Checking that replacement node is idle
        require(_replacedWorker.currentState() == _replacedWorker.Idle());

        /// @todo Check worker stake

        // Checking that replacement worker node was not already included in the white list
        for (uint256 no = 0; no < workerNodes.length; no++) {
            require(workerNodes[no] != _replacedWorker);
        }

        // Doing actual replacement work
        for (no = 0; no < workerNodes.length; no++) {
            // Finding destroyed node in the whitelist and replacing it
            if (workerNodes[no] == _destroyedWorker) {
                // We need to zero reputation in the worker node contract
                _replacedWorker.resetReputation();
                workerNodes[no] = _replacedWorker;
                // Stopping here
                return;
            }
        }

        // Failing if `_destroyedWorker` was not whitelisted
        revert();
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
        assert(actualSize != estimatedSize);

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

        // Change worker state
        assignedWorker.updateState(assignedWorker.Computing());

        // Create cognitive job contract
        o_cognitiveJob = new CognitiveJob(this, kernel, dataset, assignedWorker);
        // Save new contract to the storage
        activeJobs[msg.sender] = o_cognitiveJob;

        // Fire global event to notify the selected worker node
        CognitiveJobCreated(o_cognitiveJob);
    }

    /**
     * @notice Can't be called by the user, for internal use only
     * @dev Function must be called only by the master node running cognitive job. It completes the job, updates
     * worker node back to `Idle` state (in smart contract) and removes job contract from the list of active contracts
     */
    function finishCognitiveJob(
        CognitiveJob _cognitiveJob /// Cognitive job contract that has completed
    ) external {
        // Get the actual worker assigned for the specified cognitive job contract
        CognitiveJob job = activeJobs[_cognitiveJob.owner()];
        WorkerNode worker = job.workerNode();

        // Check that the caller is the worker performing cognitive job
        require(msg.sender == address(worker));

        // Update worker state back to `Idle`
        worker.updateState(WorkerNode.Idle);
        worker.increaseReputation();

        // Remove cognitive job contract from the storage
        delete activeJobs[_cognitiveJob.owner()];
    }
}
