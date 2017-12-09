pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Pandora.sol";
import "../contracts/Kernel.sol";
import "../contracts/Dataset.sol";
import "../contracts/WorkerNode.sol";
import "../contracts/CognitiveJob.sol";


contract TestWorkerNode {
    Pandora pandora;
    WorkerNode workerNode;

    function TestWorkerNode() {
        pandora = Pandora(DeployedAddresses.Pandora());
        workerNode = pandora.workerNodes(0);
    }

    function testWorkerWasCreated() {
        Assert.notEqual(workerNode, address(0), "Worker node must be deployed");
    }

    function testInitialState() {
        Assert.equal(workerNode.currentState(), uint(workerNode.Offline()), "WorkerNode state must be Offline upon initialization");
    }

    function testAliveReaction () {
        workerNode.alive();
        Assert.equal(workerNode.currentState(), uint(workerNode.Idle()), "WorkerNode state now must be Idle");
    }

    function testIdleState() {
        Assert.equal(workerNode.Idle(), uint(2), "Worker Idle state must have value of 2");
    }

    function testReputation() {
        Assert.equal(workerNode.reputation(), 0, "WorkerNode state must has zero reputation upon initialization");
    }

    function testPandoraReference() {
        Assert.equal(workerNode.pandora(), DeployedAddresses.Pandora(), "Worker must reference proper root Pandora contract");
    }
}
