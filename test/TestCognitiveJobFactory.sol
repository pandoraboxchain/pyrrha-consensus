pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./util/ThrowProxy.sol";
import "./util/CognitiveJobCreateProxy.sol";
import "../contracts/pandora/hooks/PandoraHooks.sol";
import "../contracts/entities/Kernel.sol";
import "../contracts/entities/Dataset.sol";
import "../contracts/nodes/IWorkerNode.sol";
import "../contracts/jobs/IComputingJob.sol";


contract TestCognitiveJobFactory {
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

    function testCreateDirectlyFailure() {
        IWorkerNode[] memory pool = new IWorkerNode[](1);
        pool[0] = workerNode;

        CognitiveJobCreateProxy createProxy = new CognitiveJobCreateProxy();
        ThrowProxy throwProxy = new ThrowProxy(address(createProxy));
        CognitiveJobCreateProxy(address(throwProxy)).create(pandora, kernel, dataset, pool);
        bool result = throwProxy.execute();
        Assert.isFalse(result, "Cognitive job should not be created outside of the main Pandora contract");
    }
}
