pragma solidity ^0.4.23;

import "../../entities/IDataEntity.sol";
import "../../nodes/IWorkerNode.sol";
import "../../entities/IKernel.sol";
import "../../entities/IDataset.sol";

contract ICognitiveJobManager {

    function getCognitiveJobDetails(bytes32 _jobId, bool isActive) public view returns (
        address kernel, address dataset, uint256 comlexity, bytes32 description, address[] activeWorkers);

    function getCognitiveJobProgressInfo(bytes32 _jobId, bool isActive) public view returns(
        uint32[] responseTimestamps, bool[] responseFlags, uint8 progress, uint8 state);

    function getCognitiveJobResults(bytes32 _jobId, bool isActive, uint8 number) public view returns(
        bytes ipfsResults);

    function activeJobsCount() view public returns (uint256);
    function isActiveJob(bytes32 job) view public returns (bool);

    function createCognitiveJob(IKernel kernel, IDataset dataset, uint256 comlexity, bytes32 description)
        external payable returns (bytes32, uint8);

    //workers interaction
    function respondToJob(bytes32 _jobId, uint8 _responseType, bool _response) external;
    function finishCognitiveJob(bytes32 _jobId) external;

    function provideResults(bytes32 _jobId, bytes _ipfsResults) external;
    function commitProgress(bytes32 _jobId, uint _percent) external;
    function checkJobQueue() public;
    function getQueueDepth() external returns (uint256);

    event CognitiveJobCreated(bytes32 _jobId);
}
