pragma solidity ^0.4.18;

import './ICognitiveJobQueue.sol';

contract CognitiveJobQueue is ICognitiveJobQueue {

    struct QueuedJob {
        IKernel kernel;
        IDataset dataset;
        uint deposit;
    }
    QueuedJob[] public queuedJobs;
    mapping(address => uint16) public queuedAddresses;


    /// @notice Returns the total count of jobs in the queue
    function queuedJobsCount(
    )
    onlyInitialized
    view
    external
    returns (
        uint o_count /// Number of jobs in the queue
    ) {
        o_count = queuedJob.length;
    }

    function addToQueue(
        IKernel _kernel,
        IDataset _dataset
    )
    internal
    returns (
        QueuedJob o_queuedJob
    ) {
        o_queuedJob = QueuedJob(_kernel, _dataset, msg.value);
        queuedJobs.push(queuedJob);
        queuedAddresses[queuedJobs.length] = uint16(activeJobs.length);
    }
}
