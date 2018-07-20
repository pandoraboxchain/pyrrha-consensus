pragma solidity ^0.4.23;

import "../../nodes/IWorkerNode.sol";
import "../../entities/IDataEntity.sol";
import "../../entities/IKernel.sol";
import "../../entities/IDataset.sol";

contract ICognitiveJobManager {

    //workers interaction
    function provideResults(bytes32 _jobId, bytes _ipfsResults) external;
    function respondToJob(bytes32 _jobId, uint8 _responseType, bool _response) external;
    function commitProgress(bytes32 _jobId, uint8 _percent) external;

    event CognitiveJobCreated(bytes32 _jobId);
}
