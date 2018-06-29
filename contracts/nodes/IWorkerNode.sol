pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../libraries/IStateMachine.sol";
import "../pandora/IPandora.sol";
import "../jobs/IComputingJob.sol";
import "./WorkerNodeStates.sol";

contract IWorkerNode is IStateMachine, Ownable, WorkerNodeStates {
    /// @notice Defines possible cases for penaltize worker nodes. Used in `WorkerNodeManager.penaltizeWorkerNode`
    enum Penalties {
        OfflineWhileGathering,
        DeclinesJob,
        OfflineWhileDataValidation,
        FalseReportInvalidData,
        OfflineWhileCognition
    }

    IPandora public pandora;
    IComputingJob public activeJob;

    function destroy() external;
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
    function withdrawBalance() external;
    function unlockFinalizedState() external;

    event WorkerDestroyed();
}

