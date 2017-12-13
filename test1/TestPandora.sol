pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/pandora/Pandora.sol";
import "../contracts/entities/Kernel.sol";
import "../contracts/entities/Dataset.sol";
import "../contracts/nodes/WorkerNode.sol";
import "../contracts/jobs/CognitiveJob.sol";
import "../contracts/pandora/factories/WorkerNodeFactory.sol";
import "../contracts/pandora/factories/CognitiveJobFactory.sol";

contract TestPandora {
    Pandora pandora;

    function beforeAll() {
        pandora = Pandora(DeployedAddresses.Pandora());
    }

    function testPandoraDeployment() {
        Assert.notEqual(pandora, address(0), "Pandora contract should be initialized");
        Assert.notEqual(pandora.workerNodeFactory(), address(0), "Pandora must have initialized worker node factory");
        Assert.notEqual(pandora.cognitiveJobFactory(), address(0), "Pandora must have initialized worker node factory");
        Assert.equal(DeployedAddresses.WorkerNodeFactory(), pandora.workerNodeFactory(),
            "Pandora must reference proper worker node factory instance");
        Assert.equal(DeployedAddresses.CognitiveJobFactory(), pandora.cognitiveJobFactory(),
            "Pandora must reference proper cognitive job factory instance");
        Assert.equal(pandora.properlyInitialized(), true, "Pandora must be properly initialized");
        Assert.equal(pandora.workerNodesCount(), 0, "There must be no initialized workers");
    }

    /*
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
    */
}
