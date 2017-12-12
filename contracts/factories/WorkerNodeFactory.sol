pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../pandora/IPandora.sol';
import '../nodes/WorkerNode.sol';

contract WorkerNodeFactory is Ownable {
    function WorkerNodeFactory() public {}

    /// @dev Creates worker node contract for the main Pandora contract and does necessary preparations of it
    /// (transferring ownership). Can be called only by a Pandora contract (Pandora is the owner of the factory)
    function create(
        address _nodeOwner /// Worker node owner. Contract ownership will be transferred to this owner upon creation
    )
    onlyOwner
    external
    returns (
        WorkerNode o_workerNode /// Worker node created by the factory
    ) {
        // Creating node
        o_workerNode = new WorkerNode(IPandora(owner));

        // Checking that it was created correctly
        assert(o_workerNode != WorkerNode(0));

        // Transferring ownership to the owner supplied by Pandora (it must be a caller of `Pandora.createWorkerNode`
        // function
        o_workerNode.transferOwnership(_nodeOwner);
    }
}
