pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import '../libraries/IStateMachine.sol';
import '../pandora/IPandora.sol';
import '../jobs/IComputingJob.sol';
import './WorkerNodeStates.sol';

contract IWorkerNode is IStateMachine, Ownable, WorkerNodeStates {
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
    IComputingJob public activeJob;
    uint256 public reputation;

    function alive() external;
    function assignJob(IComputingJob job) external;
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

