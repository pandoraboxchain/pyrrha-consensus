pragma solidity ^0.4.18;

import "../../contracts/pandora/IPandora.sol";
import "../../contracts/entities/IKernel.sol";
import "../../contracts/entities/IDataset.sol";
import "../../contracts/nodes/IWorkerNode.sol";
import "../../contracts/nodes/WorkerNode.sol";
import "../../contracts/jobs/CognitiveJob.sol";

contract WorkerNodeCreateProxy {
    function create(IPandora pandora)
    returns (WorkerNode) {
        return new WorkerNode(pandora);
    }
}
