pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./util/ThrowProxy.sol";
import "./util/WorkerNodeCreateProxy.sol";
import "../contracts/pandora/hooks/PandoraHooks.sol";
import "../contracts/nodes/WorkerNode.sol";
import "../contracts/jobs/CognitiveJob.sol";

contract TestWorkerNodeFactory {
    PandoraHooks pandora;
    IWorkerNode workerNode;

    function beforeAll() {
        pandora = PandoraHooks(DeployedAddresses.PandoraHooks());
    }

    function testCreateDirectlyFailure() {
        WorkerNodeCreateProxy createProxy = new WorkerNodeCreateProxy();
        ThrowProxy throwProxy = new ThrowProxy(address(createProxy));
        WorkerNodeCreateProxy(address(throwProxy)).create(pandora);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Worker node should not be created outside of the main Pandora contract");
    }
}
