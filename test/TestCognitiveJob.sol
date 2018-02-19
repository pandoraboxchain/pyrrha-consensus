pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./util/ThrowProxy.sol";
import "../contracts/pandora/hooks/PandoraHooks.sol";
import "../contracts/entities/Kernel.sol";
import "../contracts/entities/Dataset.sol";
import "../contracts/nodes/IWorkerNode.sol";
import "../contracts/jobs/IComputingJob.sol";


contract TestCognitiveJob {
    Pandora pandora;
    IWorkerNode workerNode;
    Kernel kernel;
    Dataset dataset;
    IComputingJob job;

    function beforeAll() {
        pandora = PandoraHooks(DeployedAddresses.PandoraHooks());
        dataset = Dataset(DeployedAddresses.Dataset());
        kernel = Kernel(DeployedAddresses.Kernel());
        workerNode = pandora.workerNodes(0);
    }

    function testCreateFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(pandora));
        Pandora(address(throwProxy)).createCognitiveJob(kernel, dataset);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Should not create cognitive job because no alive workers available");
    }

    function testWorkerAlive() {
        ThrowProxy throwProxy = new ThrowProxy(address(workerNode));
        IWorkerNode(address(throwProxy)).alive();
        bool result = throwProxy.execute();
        Assert.isTrue(result, "WorkerNode.alive function should be working");
    }

    function testCreate() {
        uint8 resultCode;
        uint resultCodeExpected = 1;
        (job, resultCode) = pandora.createCognitiveJob(kernel, dataset);
        Assert.notEqual(address(job), address(0), "Cognitive job should successfully initialize");
        Assert.equal(resultCode, resultCodeExpected, "Received result code should match with success code (1)");
    }

    function testListedInPandora() {
        uint index = pandora.jobAddresses(job);
        Assert.notEqual(index, 0, "Cognitive job should be present in job addresses list");
        Assert.equal(address(pandora.activeJobs(index - 1)), address(job),
            "Cognitive job should be present in active jobs list");
    }

    function testInitialStates() {
        Assert.equal(uint(job.currentState()), job.GatheringWorkers(), "Initial Job state should be GatheringWorkers");
        Assert.equal(uint(workerNode.currentState()), workerNode.Assigned(),
            "Initial worker state should be Assigned");
    }

    function testOwnership() {
        Assert.equal(address(job.pandora()), address(pandora),
            "Cognitive job should reference proper Pandora contract");
    }

    function testAssignment() {
        workerNode.acceptAssignment();
        Assert.equal(uint(workerNode.currentState()), workerNode.ReadyForDataValidation(),
            "Worker state now should be `ReadyForDataValidation`");
        Assert.equal(uint(job.currentState()), job.DataValidation(), "Job state now should be `DataValidation`");
    }

    function testDataValidation() {
        workerNode.processToDataValidation();
        Assert.equal(uint(workerNode.currentState()), workerNode.ValidatingData(),
            "Worker state now should be `ValidatingData`");
    }

    function testAcceptValidData() {
        workerNode.acceptValidData();
        Assert.equal(uint(workerNode.currentState()), workerNode.ReadyForComputing(),
            "Worker state now should be `ReadyForComputing`");
        Assert.equal(uint(job.currentState()), job.Cognition(), "Next state should be Cognition");
    }

    function testCognition() {
        workerNode.processToCognition();
        Assert.equal(uint(workerNode.currentState()), workerNode.Computing(),
            "Worker state now should be `Computing`");
    }

    function testResults() {
        uint originalCount = pandora.activeJobsCount();
        workerNode.provideResults("some-ipfs-address");
        Assert.equal(uint(pandora.jobAddresses(msg.sender)), 0,
            "Cognitive job should be delisted after completion");
        Assert.equal(pandora.activeJobsCount(), originalCount - 1, "Size of active jobs array must decrement");
    }

    function testEndState() {
        Assert.equal(uint(job.currentState()), job.Completed(), "Next state should be Completed");
        Assert.equal(uint(workerNode.currentState()), workerNode.Idle(),
            "Worker state now should be `Idle`");
    }
}
