pragma solidity ^0.4.18;

import "../../contracts/pandora/IPandora.sol";
import "../../contracts/entities/IKernel.sol";
import "../../contracts/entities/IDataset.sol";
import "../../contracts/nodes/IWorkerNode.sol";
import "../../contracts/nodes/WorkerNode.sol";
import "../../contracts/jobs/CognitiveJob.sol";

contract CognitiveJobCreateProxy {
    function create(IPandora pandora, IKernel kernel, IDataset dataset, IWorkerNode[] pool)
    returns (CognitiveJob) {
        return new CognitiveJob(pandora, kernel, dataset, pool);
    }
}
