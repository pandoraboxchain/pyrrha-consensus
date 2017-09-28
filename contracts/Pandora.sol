pragma solidity ^0.4.15;

import './PAN.sol';
import './LotteryEngine.sol';
import './WorkerNode.sol';
import './Kernel.sol';
import './Dataset.sol';
import './CognitiveJob.sol';

/****
 * # Pandora Smart Contract
 *
 * Main & root contract implementing the first level of Pandora Boxchain consensus
 * See section ("3.3. Proof of Cognitive Work (PoCW)" in Pandora white paper)[https://steemit.com/cryptocurrency/@pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain]
 * for more details.
 *
 * Contract token functionality is separated into a separate contract named PAN (after the name of the token)
 * and Pandora contracts just simply inherits PAN contract.
 */

contract Pandora is PAN /* final */ {

    /*****
     * ## Storage
     */

    /// Whitelist of nodes allowed to perform cognitive work as a trusted environment for the first version of
    /// the protocol implementation codenamed Pyrrha
    uint8 constant WORKERNODE_WHITELIST_SIZE = 7;
    WorkerNode[WORKERNODE_WHITELIST_SIZE] public workerNodes;

    /// List of active (=running) cognitive jobs mapped to their creators (owners of the corresponding
    /// cognitive job contracts)
    mapping(address => CognitiveJob) public activeJobs;

    /// Contract implementing lottery interface for workers selection. Only internal usage
    /// by `createCognitiveJob` function
    LotteryEngine internal workerLotteryEngine;

    /*****
     * ## Events
     */

    /// Event firing when a new cognitive job created
    event CognitiveJobCreated(CognitiveJob cognitiveJob);

    /*****
     * ## Functions
     */

    /// Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    function Pandora (address[WORKERNODE_WHITELIST_SIZE] _workerNodeOwners) {
        // Something is wrong with the compiler or Ethereum node if this check fails
        // (that's why its `assert`, not `require`)
        assert(_workerNodeOwners.length == workerNodes.length);

        for (uint8 no = 0; no < WORKERNODE_WHITELIST_SIZE; no++) {
            // Creating new worker node contract for each of the seven pre-defined owners whitelisted at the moment
            // of creation of the main Pandora contract
            WorkerNode worker = new WorkerNode(this);

            // Change ownership of the worker node contract to a pre-defined owner passed to the constructor
            worker.transferOwnership(_workerNodeOwners[no]);

            // Store newly created worker node contract
            workerNodes[no] = worker;
        }
    }

    /// Core function creating new cognitive job contract and returning it back to the caller
    /// TODO: Add payments
    function createCognitiveJob(
        Kernel kernel,
        Dataset dataset
    ) external payable returns (CognitiveJob o_cognitiveJob) {
        WorkerNode[] memory idleWorkers;
        for (uint256 no = 0; no < workerNodes.length; no++) {
            if (workerNodes[no].currentState == WorkerNode.State.Idle) {
                idleWorkers.push(workerNodes[no]);
            }
        }

        WorkerNode assignedWorker = idleWorkers[workerLotteryEngine.getRandom(idleWorkers.length)];
        assignedWorker.updateState(WorkerNode.State.Computing);
        o_cognitiveJob = new CognitiveJob(this, kernel, dataset, assignedWorker);
        activeJobs[msg.sender] = o_cognitiveJob;
        CognitiveJobCreated(o_cognitiveJob);
    }

    function finishCognitiveJob(
        CognitiveJob _cognitiveJob
    ) external {
        CognitiveJob job = activeJobs[_cognitiveJob.owner];
        job.workerNode.updateState(WorkerNode.State.Idle);
        delete activeJobs[_cognitiveJob.owner];
    }
}
