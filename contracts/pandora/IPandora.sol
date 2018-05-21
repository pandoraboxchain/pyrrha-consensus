pragma solidity ^0.4.23;

import "./token/PAN.sol";
import "./managers/WorkerNodeManager.sol";
import "./managers/CognitiveJobManager.sol";

contract IPandora is PAN, ICognitiveJobManager, IWorkerNodeManager {}
