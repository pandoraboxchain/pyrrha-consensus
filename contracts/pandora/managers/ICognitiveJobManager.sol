pragma solidity ^0.4.23;

import "../../entities/IDataEntity.sol";
import "../../nodes/IWorkerNode.sol";
import "../../jobs/IComputingJob.sol";
import "../factories/CognitiveJobFactory.sol";

contract ICognitiveJobManager {
    CognitiveJobFactory public cognitiveJobFactory;

    IComputingJob[] public activeJobs;
    mapping(address => uint16) public jobAddresses;

    function activeJobsCount() view public returns (uint256);
    function isActiveJob(IComputingJob job) view public returns (bool);

    function createCognitiveJob(IKernel kernel, IDataset dataset, uint comlexity) external payable returns (IComputingJob, uint8);
    function finishCognitiveJob() external;

    event CognitiveJobCreated(IComputingJob cognitiveJob);
}
