pragma solidity ^0.4.23;

import "../../entities/IDataEntity.sol";
import "../../nodes/IWorkerNode.sol";

contract ICognitiveJobManager {

    function getCognitiveJobDetails(bytes32 _jobId, bool isActive) public view returns (
        address, address, uint256, bytes32, bytes32[], bytes[]);

    function getCognitiveJobProgressInfo(bytes32 _jobId, bool isActive) public returns(
        uint32[], bool[], uint8, uint8);

    function cognitiveJobsCount() view public returns (uint256);
    function isActiveJob(bytes32 job) view public returns (bool);

    function createCognitiveJob(IKernel kernel, IDataset dataset, uint256 comlexity, bytes32 description)
        external payable returns (bytes32, uint8);

    //workers interaction
    function respondToJob(bytes32 _jobId, uint8 _responseType, bool _response) external;
    function finishCognitiveJob(bytes32 _jobId) external;

    function getQueueDepth() external returns (uint256);
    function provideResults(bytes32 _jobId, bytes _ipfsResults) external;
    function commitProgress(bytes32 _jobId, uint _percent) external;
    function checkJobQueue() public;
    function getQueueDepth() external returns (uint256);

    event CognitiveJobCreated(bytes32 _jobId);
}
