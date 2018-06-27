pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../nodes/WorkerNode.sol";

contract IWorkerNodeFactory is Ownable{

    event WorkerNodeOwner(address owner);

    /// @dev Creates worker node contract for the main Pandora contract and does necessary preparations of it
    /// (transferring ownership). Can be called only by a Pandora contract (Pandora is the owner of the factory)
    function create(
        address _nodeOwner /// Worker node owner. Contract ownership will be transferred to this owner upon creation
    )
    external
    returns (
        WorkerNode o_workerNode /// Worker node created by the factory
    );
}
