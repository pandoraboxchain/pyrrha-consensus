pragma solidity ^0.4.23;

import "../../entities/IDataEntity.sol";
import "../../nodes/IWorkerNode.sol";
import "../../jobs/IComputingJob.sol";
import "../factories/ICognitiveJobFactory.sol";

contract ICognitiveJobManager {
    ICognitiveJobFactory public cognitiveJobFactory;

    IComputingJob[] public cognitiveJobs;
    mapping(address => uint16) public jobAddresses;

    function cognitiveJobsCount() view public returns (uint256);
    function isActiveJob(IComputingJob job) view public returns (bool);

    function createCognitiveJob(
        IKernel kernel,
        IDataset dataset,
        uint comlexity,
        bytes32 description) external payable returns (IComputingJob, uint8);
    function finishCognitiveJob() external;

    event CognitiveJobCreated(IComputingJob cognitiveJob);
}
