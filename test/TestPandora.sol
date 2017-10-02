pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Pandora.sol";
import "../contracts/Kernel.sol";
import "../contracts/Dataset.sol";
import "../contracts/WorkerNode.sol";
import "../contracts/CognitiveJob.sol";

contract TestPandora {
    Pandora pandora;
    WorkerNode[] workerNodes;

    function TestPandora() {
        pandora = Pandora(DeployedAddresses.Pandora());
        uint count = pandora.workerNodesCount();
        for (uint no = 0; no < count; no++) {
            workerNodes.push(pandora.workerNodes(no));
        }
    }

    function testDeployedPandora() {
        Assert.notEqual(pandora, address(0), "Pandora contract should be initialized");
    }

    function testWorkerNodesCount() {
        Assert.equal(workerNodes.length, 7, "There must be exactly 7 initialized workers");
    }

    function testWorkerNodes() {
        for (uint no = 0; no < workerNodes.length; no++) {
            Assert.notEqual(workerNodes[no], address(0), "Worker must be initialized");
        }
    }

    function testDataDimEquivalence() {
        Kernel kernel = Kernel(DeployedAddresses.Kernel());
        Dataset dataset = Dataset(DeployedAddresses.Dataset());

        Assert.equal(kernel.dataDim(), dataset.dataDim(), "Kernel and dataset must have the same data dimension");
    }

    function testIdleWorkerValue() {
        uint idle = workerNodes[0].Idle();
        Assert.equal(idle, 1, "Worker Idle state must have value of 1");
    }

    function testIdleWorkers() {
        uint idle = workerNodes[0].Idle();
        for (uint no = 0; no < workerNodes.length; no++) {
            Assert.equal(workerNodes[no].currentState(), idle, "Worker must be Idle");
        }
    }

    function testCreateCognitiveJob() {
        Kernel kernel = Kernel(DeployedAddresses.Kernel());
        Dataset dataset = Dataset(DeployedAddresses.Dataset());

        CognitiveJob cognitiveJob = pandora.createCognitiveJob(kernel, dataset);

        Assert.notEqual(cognitiveJob, address(0), "Cognitive job should be initialized from within Pandora");
    }

    function testCreateCognitiveJobArtificially() {
        Kernel kernel = Kernel(DeployedAddresses.Kernel());
        Dataset dataset = Dataset(DeployedAddresses.Dataset());

        WorkerNode[] assigned;
        assigned.push(workerNodes[0]);
        Assert.notEqual(new CognitiveJob(pandora, kernel, dataset, assigned), address(0), "Cognitive job should be created");

    }

    function testPreprocessingOfCognitiveJobCreation() {
        uint256 estimatedSize = 0;
        for (uint256 no = 0; no < workerNodes.length; no++) {
            if (workerNodes[no].currentState() == workerNodes[no].Idle()) {
                estimatedSize++;
            }
        }
        Assert.notEqual(estimatedSize, 0, "Estimated size of Idle workers array must be greater than zero");

        WorkerNode[] memory idleWorkers = new WorkerNode[](estimatedSize);
        uint256 actualSize = 0;
        for (no = 0; no < workerNodes.length; no++) {
            if (workerNodes[no].currentState() == workerNodes[no].Idle()) {
                idleWorkers[actualSize++] = workerNodes[no];
            }
        }
        Assert.equal(actualSize, estimatedSize, "Actual size of Idle workers array must be equal to the estimated");

        uint256 tryNo = 0;
        uint256 randomNo;
        WorkerNode assignedWorker;
        do {
            Assert.isTrue(tryNo < 100, "Number of tries must be less then 100");
            randomNo = pandora.workerLotteryEngine().getRandom(idleWorkers.length);
            assignedWorker = idleWorkers[randomNo];
            tryNo++;
        } while (assignedWorker.currentState() != assignedWorker.Idle());

        WorkerNode[] memory assignedWorkers = new WorkerNode[](1);
        assignedWorkers[0] = assignedWorker;
    }
}
