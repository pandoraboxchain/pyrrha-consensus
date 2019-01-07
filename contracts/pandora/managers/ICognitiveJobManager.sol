pragma solidity 0.4.24;

import "../../nodes/IWorkerNode.sol";
import "../../entities/IDataEntity.sol";
import "../../entities/IKernel.sol";
import "../../entities/IDataset.sol";
import "./IEconomicController.sol";
import "./ICognitiveJobController.sol";

contract ICognitiveJobManager {

    // Controller for economic
    IEconomicController public economicController;

    // Controller for CognitiveJobs
    ICognitiveJobController public jobController;

    function getMaximumWorkerPrice() public view returns (uint256) {}

    //workers interaction
    function provideResults(bytes32 _jobId, bytes _ipfsResults) external;
    function respondToJob(bytes32 _jobId, uint8 _responseType, bool _response) external;
    function commitProgress(bytes32 _jobId, uint8 _percent) external;

    event CognitiveJobCreated(bytes32 jobId);
}
