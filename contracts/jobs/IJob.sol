pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import '../libraries/IStateMachine.sol';
import '../entities/IDataEntity.sol';
import '../pandora/IPandora.sol';
import '../nodes/INode.sol';
import './JobStates.sol';

contract IJobs is Destructible, IStateMachine {
    enum DataValidationResponse {
        Accept, Decline, Invalid
    }
}

contract ICognitiveJob is IJobs, JobStates {
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