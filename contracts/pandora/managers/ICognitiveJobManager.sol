pragma solidity 0.4.24;

import "../../nodes/IWorkerNode.sol";
import "../../entities/IDataEntity.sol";
import "../../entities/IKernel.sol";
import "../../entities/IDataset.sol";
import "./IEconomicController.sol";

contract ICognitiveJobManager {

    // Controller for economic
    IEconomicController public economicController;

    //workers interaction
    function provideResults(bytes32 _jobId, bytes _ipfsResults) external;
    function respondToJob(bytes32 _jobId, uint8 _responseType, bool _response) external;
    function commitProgress(bytes32 _jobId, uint8 _percent) external;

    event CognitiveJobCreated(bytes32 jobId);
}
