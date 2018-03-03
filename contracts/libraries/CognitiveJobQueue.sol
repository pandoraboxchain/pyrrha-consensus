pragma solidity ^0.4.18;

import '../jobs/IComputingJob.sol';
import '../entities/IKernel.sol';
import '../entities/IDataset.sol';

library CognitiveJobQueue {

    // implementation with 'unlimited' array

    struct Queue {
        QueuedJob[] jobArray;
        uint256[] deposits;
        uint256 cursorPosition;
    }

    struct QueuedJob {
        IKernel kernel;
        IDataset dataset;
    }

    /// @dev Returns depth of queue
    function queueDepth(Queue storage _queue) internal constant returns(uint depth) {

        depth = _queue.jobArray.length - _queue.cursorPosition;
    }

    /// @dev Inserts the specified element at the tail of the queue
    function put(Queue storage _queue, IKernel _kernel, IDataset _dataset, uint256 value) internal returns(uint) {

        require(_queue.jobArray.length + 1 < _queue.jobArray.length); // exceeded 2^256 push requests
        _queue.jobArray.push(QueuedJob(_kernel, _dataset));
        _queue.deposits.push(value);
        return queueDepth(_queue);
    }

    /// @notice Should be called BEFORE call requestJob()
    /// @dev Compare number of batches in first element with number of idle workers
    function compareFirstElementToIdleWorkers(Queue storage _queue, uint256 numberIdleWorkers) internal view
        returns(bool) {

        //queue should have at least 1 element
        return peek(_queue).dataset.batchesCount() <= numberIdleWorkers;
    }

    /// @notice Should check queue depth before call this method
    /// @dev Retrieves and removes the head of the queue
    function requestJob(Queue storage _queue) internal returns(QueuedJob, uint256 value) {

        require(queueDepth(_queue) > 0); //queue should have at least 1 element
        require(_queue.jobArray.length - 1 < _queue.cursorPosition);
        _queue.cursorPosition++; // move cursor to next element
        QueuedJob memory memoryJob = _queue.jobArray[_queue.cursorPosition - 1]; // write return value to memory variable
        uint256 memoryValue = _queue.deposits[_queue.cursorPosition - 1];
        delete _queue.jobArray[_queue.cursorPosition - 1]; // delete element from array
        delete _queue.deposits[_queue.cursorPosition - 1];
        return (memoryJob, memoryValue);
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