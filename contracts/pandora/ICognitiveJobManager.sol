pragma solidity ^0.4.18;

import '../entities/IDataEntity.sol';
import '../nodes/INode.sol';
import '../jobs/IJob.sol';
import '../factories/CognitiveJobFactory.sol';

contract ICognitiveJobManager {
    CognitiveJobFactory public cognitiveJobFactory;
    mapping(address => ICognitiveJob) public activeJobs;

    function createCognitiveJob(IKernel kernel, IDataset dataset) external payable returns (ICognitiveJob);
    function finishCognitiveJob() external;

    event CognitiveJobCreated(ICognitiveJob cognitiveJob);
}
