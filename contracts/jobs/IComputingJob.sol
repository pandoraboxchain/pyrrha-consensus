pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "../libraries/IStateMachine.sol";
import "../entities/IDataEntity.sol";
import "../pandora/IPandora.sol";
import "../nodes/IWorkerNode.sol";

contract IComputingJob is IStateMachine, Destructible {

    enum DataValidationResponse {
        Accept, Decline, Invalid
    }

	// Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
	// to indicate that contract had being destroyed
	uint8 public constant Destroyed = 0xFF;

	// Reserved system state not participating in transition table. Since contract creation all variables are
	// initialized to zero and contract state will be zero until it will be initialized with some definite state
	uint8 public constant Uninitialized = 0;
	uint8 public constant GatheringWorkers = 1;
	uint8 public constant InsufficientWorkers = 2;
	uint8 public constant DataValidation = 3;
	uint8 public constant InvalidData = 4;
	uint8 public constant Cognition = 5;
	uint8 public constant PartialResult = 6;
	uint8 public constant Completed = 7;

    IPandora public pandora;
    IKernel public kernel;
    IDataset public dataset;
    uint256 public batches;
    uint256 public complexity; //todo find better name
    uint256 public jobType;
    bytes32 public description;
    IWorkerNode[] public activeWorkers;
    IWorkerNode[] public workersPool;

    uint8 public progress;
    bytes[] public ipfsResults;

	function initialize() external;
    function activeWorkersCount() view external returns(uint256);
    function didWorkerCompute(uint no) view external returns(bool);

    function reportOfflineWorker(IWorkerNode reported) payable external;
    function gatheringWorkersResponse(bool acceptanceFlag) external;
    function dataValidationResponse(DataValidationResponse response) external;
    function commitProgress(uint8 percent) external;
    function completeWork(bytes ipfs) external;

    event WorkersUpdated();
    event WorkersNotFound();
    event DataValidationStarted();
    event DataValidationFailed();
    event CognitionStarted();
    event CognitionProgressed(uint8 precent);
    event CognitionCompleted(bool partialResult);
}
