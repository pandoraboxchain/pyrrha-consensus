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
        Assert.equal(idle, 2, "Worker Idle state must have value of 2");
    }

    function testIdleWorkers() {
        uint offline = workerNodes[0].Offline();
        for (uint no = 0; no < workerNodes.length; no++) {
            Assert.equal(workerNodes[no].currentState(), offline, "Worker must be Offline");
        }
    }

    function testCreateCognitiveJob() {
        Kernel kernel = Kernel(DeployedAddresses.Kernel());
        Dataset dataset = Dataset(DeployedAddresses.Dataset());
        WorkerNode worker = workerNodes[0];

        worker.alive();
        CognitiveJob cognitiveJob = pandora.createCognitiveJob(kernel, dataset);

        Assert.notEqual(cognitiveJob, address(0), "Cognitive job should be initialized from within Pandora");
    }

    function testCreateCognitiveJobArtificially() {
        Kernel kernel = Kernel(DeployedAddresses.Kernel());
        Dataset dataset = Dataset(DeployedAddresses.Dataset());

        WorkerNode[] storage assigned;
        assigned.push(workerNodes[0]);
        Assert.equal(new CognitiveJob(pandora, kernel, dataset, assigned), address(0), "Cognitive job should not be created putside of Pandora main contract");

    }
}
