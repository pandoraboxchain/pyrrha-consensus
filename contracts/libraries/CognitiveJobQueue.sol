pragma solidity ^0.4.18;

import '../jobs/IComputingJob.sol';
import '../entities/IKernel.sol';
import '../entities/IDataset.sol';

library CognitiveJobQueue {

    struct QueuedJob {
        IKernel kernel;
        IDataset dataset;
    }

    struct Queue {
        QueuedJob[] jobArray;
        uint256 cursorPosition;
    }

    /// @dev Returns depth of queue
    function queueDepth(Queue storage _queue) internal constant returns(uint depth) {

        depth = _queue.jobArray.length - _queue.cursorPosition;
    }

    /// @dev Inserts the specified element at the tail of the queue
    function put(Queue storage _queue, IKernel _kernel, IDataset _dataset) internal returns(uint) {

        require(_queue.jobArray.length + 1 < _queue.jobArray.length); // exceeded 2^256 push requests
        _queue.jobArray[_queue.cursorPosition] = QueuedJob(_kernel, _dataset);
        return queueDepth(_queue);
    }

    /// @dev Retrieves and removes the head of the queue
    function poll(Queue storage _queue) internal returns(QueuedJob) {

        require(queueDepth(_queue) > 0); //queue should have at least 1 element
        require(_queue.jobArray.length - 1 < _queue.cursorPosition);
        _queue.cursorPosition++; // move cursor to next element
        QueuedJob memory memoryJob = _queue.jobArray[_queue.cursorPosition - 1]; // write return value to memory variable
        delete _queue.jobArray[_queue.cursorPosition - 1]; // delete element from array
        return memoryJob;
    }
}