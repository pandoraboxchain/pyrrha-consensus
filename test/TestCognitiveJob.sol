pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Pandora.sol";
import "../contracts/Kernel.sol";
import "../contracts/Dataset.sol";
import "../contracts/WorkerNode.sol";
import "../contracts/CognitiveJob.sol";


contract TestCognitiveJob {
    Pandora pandora;
    WorkerNode workerNode;
    Kernel kernel;
    Dataset dataset;
    CognitiveJob job;

    function TestCognitiveJob(){
        pandora = Pandora(DeployedAddresses.Pandora());
        kernel = Kernel(DeployedAddresses.Kernel());
        dataset = Dataset(DeployedAddresses.Dataset());

        workerNode = pandora.workerNodes(0);

        workerNode.alive();
    }

    function beforeAll()  {
        job = pandora.createCognitiveJob(kernel, dataset);
    }

    function testCreation() {
        Assert.notEqual(address(job), address(0), "Cognitive job must successgully initialize");
        Assert.equal(address(job.pandora()), address(pandora), "Cognitive job must reference proper Pandora contract");
    }

    function testListedInPandora() {
        Assert.equal(address(pandora.activeJobs(job)), address(job), "Cognitive job must be present in active jobs list");
    }

    function testInitialStates() {
        Assert.equal(uint(job.currentState()), job.GatheringWorkers(), "Initial Job state must be GatheringWorkers");
        Assert.equal(uint(workerNode.currentState()), workerNode.Assigned(), "Initial worker state must be Assigned");
    }

    function testNormalWorkflow() {
        workerNode.acceptAssignment();
        Assert.equal(uint(workerNode.currentState()), workerNode.ReadyForDataValidation(),
                     "Worker state now must be `ReadyForDataValidation`");
        Assert.equal(uint(job.currentState()), job.DataValidation(), "Job state now must be `DataValidation`");

        workerNode.processToDataValidation();
        Assert.equal(uint(workerNode.currentState()), workerNode.ValidatingData(),
                     "Worker state now must be `ValidatingData`");

        workerNode.acceptValidData();
        Assert.equal(uint(workerNode.currentState()), workerNode.ReadyForComputing(),
                     "Worker state now must be `ReadyForComputing`");
        Assert.equal(uint(job.currentState()), job.Cognition(), "Next state must be Cognition");

        workerNode.processToCognition();
        Assert.equal(uint(workerNode.currentState()), workerNode.Computing(),
                     "Worker state now must be `Computing`");

        workerNode.provideResults("some-ipfs-address");
        Assert.equal(uint(job.currentState()), job.Completed(), "Next state must be Completed");
        Assert.equal(address(pandora.activeJobs(msg.sender)), address(0), "Cognitive job must be delisted after completion");
    }
}
