pragma solidity ^0.4.18;

import '../../entities/IDataEntity.sol';
import '../../nodes/IWorkerNode.sol';
import '../../jobs/IComputingJob.sol';
import '../factories/CognitiveJobFactory.sol';

contract ICognitiveJobManager {
    CognitiveJobFactory public cognitiveJobFactory;
    mapping(address => IComputingJob) public activeJobs;

    function createCognitiveJob(IKernel kernel, IDataset dataset) external payable returns (IComputingJob);
    function finishCognitiveJob() external;

    event CognitiveJobCreated(IComputingJob cognitiveJob);
}
