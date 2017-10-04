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
        workerNode = WorkerNode(DeployedAddresses.WorkerNode());
        pandora = Pandora(DeployedAddresses.Pandora());
        kernel = Kernel(DeployedAddresses.Kernel());
        dataset = Dataset(DeployedAddresses.Dataset());

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
        Assert.equal(uint(job.currentState()), job.GatheringWorkers(), "Next state must be DataValidation");

        //job.dataValidationResponse(CognitiveJob.DataValidationResponse.Accept);
        //Assert.equal(uint(job.currentState()), job.Cognition(), "NExt state must be Cognition");

        //job.completeWork("some-ipfs-address");
        //Assert.equal(uint(job.currentState()), job.Completed(), "NExt state must be Completed");
        //Assert.equal(address(pandora.activeJobs(msg.sender)), address(0), "Cognitive job must be delisted after completion");
    }
}
