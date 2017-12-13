pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./util/ThrowProxy.sol";
import "../contracts/pandora/hooks/PandoraHooks.sol";
import "../contracts/entities/Kernel.sol";
import "../contracts/entities/Dataset.sol";
import "../contracts/nodes/WorkerNode.sol";
import "../contracts/jobs/CognitiveJob.sol";
import "../contracts/pandora/factories/WorkerNodeFactory.sol";
import "../contracts/pandora/factories/CognitiveJobFactory.sol";

contract TestPandora {
    PandoraHooks pandora;
    WorkerNodeFactory nodeFactory;
    CognitiveJobFactory jobFactory;
    Dataset dataset;
    Kernel kernel;
    IWorkerNode workerNode;

    function beforeAll() {
        pandora = PandoraHooks(DeployedAddresses.PandoraHooks());
        nodeFactory = WorkerNodeFactory(DeployedAddresses.WorkerNodeFactory());
        jobFactory = CognitiveJobFactory(DeployedAddresses.CognitiveJobFactory());
        dataset = Dataset(DeployedAddresses.Dataset());
        kernel = Kernel(DeployedAddresses.Kernel());
    }

    function testDeployed() {
        Assert.notEqual(pandora, address(0), "Pandora contract should be deployed");
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
        Assert.isFalse(result, "Worker node factory should not allow changing its ownership");
    }

    function testJobFactoryOwnershipTransferFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(jobFactory));
        Pandora(address(throwProxy)).transferOwnership(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Cognitive job factory should not allow changing its ownership");
    }

    function testNodeFactoryDirectAccessFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(nodeFactory));
        WorkerNodeFactory(address(throwProxy)).create(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Worker node factory should not allow creating worker nodes outside of Pandora");
    }

    function testJobFactoryDirectAccessFailure() {
        IWorkerNode[] memory pool = new IWorkerNode[](1);
        pool[0] = IWorkerNode(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);

        ThrowProxy throwProxy = new ThrowProxy(address(nodeFactory));
        CognitiveJobFactory(address(throwProxy)).create(kernel, dataset, pool);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Worker node factory should not allow creating cognitive jobs outside of Pandora");
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
        Assert.equal(pandora.workerNodesCount(), 1, "There must be a single initialized workers");
    }

    function testJobs() {
        Assert.equal(pandora.activeJobsCount(), 0, "There must be no initialized workers");
    }

    function testWhitelistedOwners() {
        Assert.equal(pandora.hook_whitelistedOwner(0), msg.sender, "There must be first whitelisted non-zero owner");

        uint count = pandora.hook_whitelistedOwnerCount();
        Assert.equal(count, 3, "There must be exactly three whitelisted worker node owners");
        for (uint no = 0; no < count; no++) {
            Assert.notEqual(pandora.hook_whitelistedOwner(no), address(0), "There must be second whitelisted non-zero owner");
        }
    }

    function testWorkerNodeCreateFailure() {
        ThrowProxy throwProxy = new ThrowProxy(address(pandora));
        PandoraHooks(address(throwProxy)).createWorkerNode();
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Worker node must not be created by a non-whitelisted address");
    }

    function testWorkerDeployed() {
        workerNode = pandora.workerNodes(0);
        Assert.notEqual(workerNode, address(0), "Worker node must be deployed");
    }

    function testWorkerInitialState() {
        Assert.equal(workerNode.currentState(), uint(workerNode.Offline()), "WorkerNode state must be Offline upon initialization");
    }

    function testWorkerAliveReaction () {
        workerNode.alive();
        Assert.equal(workerNode.currentState(), uint(workerNode.Idle()), "WorkerNode state now must be Idle");
    }

    function testWorkerIdleState() {
        Assert.equal(workerNode.Idle(), uint(2), "Worker Idle state must have value of 2");
    }

    function testWorkerReputation() {
        Assert.equal(workerNode.reputation(), 0, "WorkerNode state must has zero reputation upon initialization");
    }

    function testWorkerPandoraReference() {
        Assert.equal(workerNode.pandora(), DeployedAddresses.PandoraHooks(), "Worker must reference proper root Pandora contract");
    }
}
