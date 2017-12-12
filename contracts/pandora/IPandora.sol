pragma solidity ^0.4.18;

import './PAN.sol';
import './WorkerNodeManager.sol';
import './CognitiveJobManager.sol';

contract IPandora is PAN, Ownable, ICognitiveJobManager, IWorkerNodeManager {
}
