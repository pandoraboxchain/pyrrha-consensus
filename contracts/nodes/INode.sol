pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import '../libraries/IStateMachine.sol';
import '../pandora/IPandora.sol';
import '../jobs/IJob.sol';
import './NodeStates.sol';

contract INode is Ownable, IStateMachine {
}

contract IWorkerNode is INode, WorkerNodeStates {
    /// @notice Defines possible cases for penaltize worker nodes. Used in `WorkerNodeManager.penaltizeWorkerNode`
    enum Penalties {
        OfflineWhileGathering,
        DeclinesJob,
        OfflineWhileDataValidation,
        FalseReportInvalidData,
        OfflineWhileCognition
    }

    function destroy() external;

    IPandora public pandora;
    ICognitiveJob public activeJob;
    uint256 public reputation;

    function alive() external;
    function assignJob(ICognitiveJob job) external;
    function cancelJob() external;
    function acceptAssignment() external;
    function declineAssignment() external;
    function processToDataValidation() external;
    function acceptValidData() external;
    function declineValidData() external;
    function reportInvalidData() external;
    function processToCognition() external;
    function provideResults(bytes ipfs) external;
    function increaseReputation() external;
    function decreaseReputation() external;
    function resetReputation() external;
    function maxPenalty() external;
    function deathPenalty() external;
    function withdrawBalance() external;

    event WorkerDestroyed();
}

contract IVerifierNode is IWorkerNode {
}

contract IArbiterNode is IVerifierNode {
}
