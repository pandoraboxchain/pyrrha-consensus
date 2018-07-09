pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "../libraries/IStateMachine.sol";
import "../entities/IDataEntity.sol";
import "../pandora/IPandora.sol";
import "../nodes/IWorkerNode.sol";

contract IComputingJob is IStateMachine, Destructible {

}
