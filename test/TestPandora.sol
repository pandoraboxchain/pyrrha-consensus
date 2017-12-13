pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/pandora/Pandora.sol";
import "../contracts/entities/Kernel.sol";
import "../contracts/entities/Dataset.sol";
import "../contracts/nodes/WorkerNode.sol";
import "../contracts/jobs/CognitiveJob.sol";
import "../contracts/pandora/factories/WorkerNodeFactory.sol";
import "../contracts/pandora/factories/CognitiveJobFactory.sol";

// Proxy contract for testing throws
contract ThrowProxy {
    address public target;
    bytes data;

    function ThrowProxy(address _target) {
        target = _target;
    }

    //prime the data using the fallback function.
    function() {
        data = msg.data;
    }

    function execute() returns (bool) {
        return target.call(data);
    }
}

contract TestPandora {
    Pandora pandora;
    WorkerNodeFactory nodeFactory;
    CognitiveJobFactory jobFactory;

    function beforeAll() {
        pandora = Pandora(DeployedAddresses.Pandora());
        nodeFactory = WorkerNodeFactory(DeployedAddresses.WorkerNodeFactory());
        jobFactory = CognitiveJobFactory(DeployedAddresses.CognitiveJobFactory());
    }

    function testDeployed() {
        Assert.notEqual(pandora, address(0), "Pandora contract should be initialized");
    }

    function testOwnershipTransferFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(pandora));
        Pandora(address(throwProxy)).transferOwnership(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Pandora should not allow to re-initialize itself");
    }

    function testFactories() {
        Assert.notEqual(pandora.workerNodeFactory(), address(0), "Pandora must have initialized worker node factory");
        Assert.notEqual(pandora.cognitiveJobFactory(), address(0), "Pandora must have initialized worker node factory");
    }

    function testNodeFactorySetup() {
        Assert.equal(nodeFactory, pandora.workerNodeFactory(),
            "Pandora must reference proper worker node factory instance");
    }

    function testJobFactorySetup() {
        Assert.equal(jobFactory, pandora.cognitiveJobFactory(),
            "Pandora must reference proper cognitive job factory instance");
    }

    function testNodeFactoryOwnership() {
        Assert.equal(nodeFactory.owner(), pandora, "Worker node factory must be owned by Pandora contract");
    }

    function testJobFactoryOwnership() {
        Assert.equal(jobFactory.owner(), pandora, "Cognitive job factory must be owned by Pandora contract");
    }

    function testNodeFactoryOwnershipTransferFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(nodeFactory));
        Pandora(address(throwProxy)).transferOwnership(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Worker node factory should not allow to change its ownership");
    }

    function testJobFactoryOwnershipTransferFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(jobFactory));
        Pandora(address(throwProxy)).transferOwnership(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Cognitive job factory should not allow to change its ownership");
    }

    function testPandoraInitialization() {
        Assert.equal(pandora.initialized(), true, "Pandora must be properly initialized");
    }

    function testReinitializationFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(pandora));
        Pandora(address(throwProxy)).initialize();
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Pandora should not allow to re-initialize itself");
    }

    function testWorkers() {
        Assert.equal(pandora.workerNodesCount(), 0, "There must be no initialized workers");
    }

    function testJobs() {
        Assert.equal(pandora.activeJobsCount(), 0, "There must be no initialized workers");
    }
}
