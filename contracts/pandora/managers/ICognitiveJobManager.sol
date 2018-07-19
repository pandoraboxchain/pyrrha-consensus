pragma solidity ^0.4.23;

import "../../nodes/IWorkerNode.sol";
import "../../entities/IDataEntity.sol";
import "../../entities/IKernel.sol";
import "../../entities/IDataset.sol";

contract ICognitiveJobManager {

    function activeJobsCount() view public returns (uint256);

    function isActiveJob(bytes32 _jobId) view public returns (bool);

    function getCognitiveJobDetails(bytes32 _jobId, bool _isActive) public view returns (
        address kernel, address dataset, uint256 comlexity, bytes32 description, address[] activeWorkers);

    function getCognitiveJobResults(bytes32 _jobId, bool _isActive, uint8 _index) public view returns(
        bytes ipfsResults);

    function getCognitiveJobProgressInfo(bytes32 _jobId, bool _isActive) public view returns(
        uint32[] responseTimestamps, bool[] responseFlags, uint8 progress, uint8 state);

    //workers interaction
    function provideResults(bytes32 _jobId, bytes _ipfsResults) external;
    function respondToJob(bytes32 _jobId, uint8 _responseType, bool _response) external;
    function commitProgress(bytes32 _jobId, uint8 _percent) external;

    event CognitiveJobCreated(bytes32 _jobId);
}
