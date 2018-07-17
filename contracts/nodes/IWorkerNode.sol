pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../libraries/IStateMachine.sol";
import "./WorkerNodeStates.sol";

contract IWorkerNode is IStateMachine, Ownable, WorkerNodeStates {
    /// @notice Defines possible cases for penalize worker nodes. Used in `WorkerNodeManager.penaltizeWorkerNode`
    enum Penalties {
        OfflineWhileGathering,
        DeclinesJob,
        OfflineWhileDataValidation,
        FalseReportInvalidData,
        OfflineWhileCognition
    }

    bytes32 public activeJob;

    function destroy() external;
    function alive() external;
    function assignJob(bytes32 _jobId) external;
    function cancelJob() external;
    function acceptAssignment() external;
    function declineAssignment() external;
    function processToDataValidation() external;
    function acceptValidData() external;
    function declineValidData() external;
    function reportInvalidData() external;
    function processToCognition() external;
    function provideResults(bytes _ipfsAddress) external;
    function withdrawBalance() external;

    event WorkerDestroyed();
}

