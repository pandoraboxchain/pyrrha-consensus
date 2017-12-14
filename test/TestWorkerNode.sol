pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./util/ThrowProxy.sol";
import "../contracts/pandora/hooks/PandoraHooks.sol";
import "../contracts/nodes/WorkerNode.sol";
import "../contracts/jobs/CognitiveJob.sol";

contract TestWorkerNode {
    PandoraHooks pandora;
    IWorkerNode workerNode;

    function beforeAll() {
        pandora = PandoraHooks(DeployedAddresses.PandoraHooks());
    }

    function testDeployed() {
        workerNode = pandora.workerNodes(0);
        Assert.notEqual(workerNode, address(0), "Worker node must be deployed");
    }

    function testInitialState() {
        Assert.equal(workerNode.currentState(), uint(workerNode.Offline()), "WorkerNode state must be Offline upon initialization");
    }

    function testAliveReaction () {
        workerNode.alive();
        Assert.equal(workerNode.currentState(), uint(workerNode.Idle()), "WorkerNode state now must be Idle");
    }

    function testIdleValue() {
        Assert.equal(workerNode.Idle(), uint(2), "Worker Idle state must have value of 2");
    }

    function testReputation() {
        Assert.equal(workerNode.reputation(), 0, "WorkerNode state must has zero reputation upon initialization");
    }

    function testPandoraReference() {
        Assert.equal(workerNode.pandora(), DeployedAddresses.PandoraHooks(), "Worker must reference proper root Pandora contract");
    }
}
