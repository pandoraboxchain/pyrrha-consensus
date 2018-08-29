pragma solidity ^0.4.23;


import "../factories/WorkerNodeFactory.sol";
import "../../nodes/IWorkerNode.sol";

contract IWorkerNodeManager {
    WorkerNodeFactory public workerNodeFactory;
    IWorkerNode[] public workerNodes;
    mapping(address => uint16) public workerAddresses;

    /// @notice Returns count of registered worker nodes
    function workerNodesCount() public view returns (uint);

    function createWorkerNode() external returns (IWorkerNode);
    function penaltizeWorkerNode(IWorkerNode guilty, IWorkerNode.Penalties reason) external;
    function destroyWorkerNode(IWorkerNode node) external;

    event WorkerNodeCreated(IWorkerNode workerNode);
    event WorkerNodeDestroyed(IWorkerNode workerNode);
}
