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
        _queue.jobArray.push(QueuedJob(_kernel, _dataset));
        return queueDepth(_queue);
    }

    /// @dev Returns first QueuedJob in queue, if no elements - returns None value;
    function requestJob(Queue storage _queue, uint128 numberIdleWorkers) internal returns(QueuedJob) {

        require(queueDepth(_queue) > 0); //queue should have at least 1 element

        // Number of batches should be less then number of Idle workers
        if (peek(_queue).dataset.batchesCount <= numberIdleWorkers) {
            return poll(_queue);
        } else {
            return QueuedJob(0);
        }
    }

    /// @dev Retrieves and removes the head of the queue
    function poll(Queue storage _queue) private returns(QueuedJob) {

        require(queueDepth(_queue) > 0); //queue should have at least 1 element
        require(_queue.jobArray.length - 1 < _queue.cursorPosition);
        _queue.cursorPosition++; // move cursor to next element
        QueuedJob memory memoryJob = _queue.jobArray[_queue.cursorPosition - 1]; // write return value to memory variable
        delete _queue.jobArray[_queue.cursorPosition - 1]; // delete element from array
        return memoryJob;
    }

    /// @dev Retrieves the head of the queue
    function peek(Queue storage _queue) private returns(QueuedJob) {

        require(queueDepth(_queue) > 0); //queue should have at least 1 element
        require(_queue.jobArray.length - 1 < _queue.cursorPosition);
        return _queue.jobArray[_queue.cursorPosition];
    }

    /// @dev Removes the head of the queue
    function remove(Queue storage _queue) private {

        require(queueDepth(_queue) > 0); //queue should have at least 1 element
        _queue.cursorPosition++; // move cursor to next element
        delete _queue.jobArray[_queue.cursorPosition - 1]; // delete element from array
    }
}