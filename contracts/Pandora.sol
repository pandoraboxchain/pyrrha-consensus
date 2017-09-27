pragma solidity ^0.4.15;

import './PAN.sol';
import './LotteryEngine.sol';
import './WorkerNode.sol';
import './Kernel.sol';
import './Dataset.sol';
import './CognitiveJob.sol';

contract Pandora is PAN {
    WorkerNode[7] public workerNodes;
    mapping(address => CognitiveJob) public activeJobs;

    LotteryEngine internal workerLotteryEngine;

    event CognitiveJobCreated(CognitiveJob cognitiveJob);

    function Pandora (address[7] _workerNodeOwners) {
        for (uint8 no = 0; no < 7; no++) {
            WorkerNode worker = new WorkerNode(this);
            worker.transferOwnership(_workerNodeOwners[no]);
            workerNodes[no] = worker;
        }
    }

    function createCognitiveJob(
        Kernel kernel,
        Dataset dataset
    ) external returns (CognitiveJob o_cognitiveJob) {
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
