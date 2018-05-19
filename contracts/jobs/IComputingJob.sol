pragma solidity 0.4.23;

import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "../libraries/IStateMachine.sol";
import "../entities/IDataEntity.sol";
import "../pandora/IPandora.sol";
import "../nodes/IWorkerNode.sol";
import "./JobStates.sol";

contract IComputingJob is IStateMachine, Destructible, JobStates {
    enum DataValidationResponse {
        Accept, Decline, Invalid
    }

    function initialize() external;

    IPandora public pandora;
    IKernel public kernel;
    IDataset public dataset;
    uint8 public batches;
    IWorkerNode[] public activeWorkers;
    IWorkerNode[] public workersPool;

    uint8 public progress;
    bytes[] public ipfsResults;

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
