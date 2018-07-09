pragma solidity ^0.4.23;

import "../libraries/StateMachine.sol";
import "./IComputingJob.sol";

/*

 */

contract CognitiveJob is IComputingJob, StateMachine /* final */ {


    /**
     * ## Main functionality
     */

    //removed
    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
    }

    //removed
    modifier onlyActiveWorkers() {
        IWorkerNode workerNode;
        (workerNode,) = _getWorkerFromSender();
        require(workerNode != IWorkerNode(0));
        require(msg.sender == address(workerNode));
        _;
    }

    //implemented
    function _getWorkerIndex(IWorkerNode _worker) private view returns (uint256) {
        for (uint256 index = 0; index < activeWorkers.length; index++) {
            if (_worker == address(activeWorkers[index])) {
                return index;
            }
        }
        return uint256(-1);
    }

    //removed
    function ipfsResultsCount() public view returns (uint256 count) {
        count = ipfsResults.length;
    }

    //removed
    function _getWorkerFromSender() private view returns (IWorkerNode o_workerNode, uint256 o_workerIndex) {
        o_workerIndex = _getWorkerIndex(IWorkerNode(msg.sender));
        if (o_workerIndex > activeWorkers.length) {
            return (IWorkerNode(0), uint256(-1));
        }
        o_workerNode = activeWorkers[o_workerIndex];
    }

    //no need to implement so far
    function _replaceWorker(uint256 workerIndex) private requireStates2(DataValidation, Cognition) {
        IWorkerNode replacementWorker;
        do {
            if (workersPool.length == 0) {
                _insufficientWorkers();
                return;
            }
            replacementWorker = workersPool[workersPool.length - 1];
            workersPool.length = workersPool.length - 1;
        } while (replacementWorker.currentState() != replacementWorker.Idle());

        acceptionFlags[workerIndex] = false; // no response is given from the new worker yet
        responseTimestamps[workerIndex] = block.timestamp;
        activeWorkers[workerIndex] = replacementWorker;
        replacementWorker.assignJob(this);
        emit WorkersUpdated();
    }

    //no need to implement so far
    function _insufficientWorkers() private requireActiveStates {
        for (uint no = 0; no < activeWorkers.length; no++) {
            activeWorkers[no].cancelJob();
        }

        if (stateMachine.currentState == Cognition) {
            _transitionToState(PartialResult);
        } else {
            _transitionToState(InsufficientWorkers);
        }
    }

    // no need to implement so far
    function _cleanStorage() private {
        workersPool.length = 0;
        activeWorkers.length = 0;
        ipfsResults.length = 0;
        acceptionFlags.length = 0;
        responseTimestamps.length = 0;
    }

    //todo implement in lib!
    function _trackOfflineWorkers() private requireActiveStates {
        for (uint256 no = 0; no < responseTimestamps.length; no++) {
            if (block.timestamp - responseTimestamps[no] > WORKER_TIMEOUT) {
                IWorkerNode guiltyWorker = activeWorkers[no];
                IWorkerNode.Penalties penalty;
                if (stateMachine.currentState == GatheringWorkers) {
                    penalty = IWorkerNode.Penalties.OfflineWhileGathering;
                } else if (stateMachine.currentState == DataValidation) {
                    penalty = IWorkerNode.Penalties.OfflineWhileDataValidation;
                } else if (stateMachine.currentState == Cognition) {
                    penalty = IWorkerNode.Penalties.OfflineWhileCognition;
                } else {
                    revert();// This should not happen due to requireActiveStates function modifier
                }
                pandora.penaltizeWorkerNode(guiltyWorker, penalty);
                _replaceWorker(no);
            }
        }
    }

    // implemented
    function _processAcceptanceResponse(bool _flag) private {
        IWorkerNode reportingWorker;
        uint256 workerIndex;
        (reportingWorker, workerIndex) = _getWorkerFromSender();
        require(reportingWorker != IWorkerNode(0));

        if (_flag == false) {
            _replaceWorker(workerIndex);
            pandora.penaltizeWorkerNode(reportingWorker, IWorkerNode.Penalties.OfflineWhileGathering);
        } else {
            acceptionFlags[workerIndex] = true;
            responseTimestamps[workerIndex] = block.timestamp;
            _trackOfflineWorkers();
            if (isAllWorkersAccepted()) {
                updateResponses();
                _transitionToState(DataValidation);
            }
        }
    }

    function _processValidationResponse(bool _flag) private {
        IWorkerNode reportingWorker;
        uint256 workerIndex;
        (reportingWorker, workerIndex) = _getWorkerFromSender();
        require(reportingWorker != IWorkerNode(0));

        if (_flag == false) {
            _replaceWorker(workerIndex);
            pandora.penaltizeWorkerNode(reportingWorker, IWorkerNode.Penalties.DeclinesJob);
        } else {
            validationFlags[workerIndex] = true;
            responseTimestamps[workerIndex] = block.timestamp;
            _trackOfflineWorkers();
            if (isAllWorkersValidated()) {
                updateResponses();
                _transitionToState(Cognition);
            }
        }
    }

    ///@dev Reset all response flags after gathering and cognition start
    function updateResponses() private {
        for (uint256 i = 0; i < activeWorkers.length; i++) {
            responseTimestamps[i] = block.timestamp;
        }
    }

    //no need to implement
    function initialize()
    external
    onlyPandora
    {
        // Select initial worker
        activeWorkers = new IWorkerNode[](batches);
        responseTimestamps = new uint[](batches);
        acceptionFlags = new bool[](batches);
        validationFlags = new bool[](batches);
        completionFlags = new bool[](batches);
        ipfsResults = new bytes[](batches);
        for (uint8 batch = 0; batch < batches; batch++) {
            responseTimestamps[batch] = block.timestamp;
            activeWorkers[batch] = workersPool[batch];
            activeWorkers[batch].assignJob(this);
        }
        for (uint16 pool = batch; pool < workersPool.length; pool++) {
            workersPool.push(workersPool[pool]);
        }

        _transitionToState(GatheringWorkers);
        emit WorkersUpdated();
    }

    /// @dev Main entry point for
    /// (Witnessing worker nodes went offline)[https://github.com/pandoraboxchain/techspecs/wiki/Witnessing-worker-nodes-going-offline]
    /// workflow
    function reportOfflineWorker(IWorkerNode _reportedWorker)
    payable
    external
    requireActiveStates {
        /// @todo accept deposit
        uint256 reportedIndex = _getWorkerIndex(_reportedWorker);
        if (block.timestamp - responseTimestamps[reportedIndex] > WORKER_TIMEOUT) {
            /// @todo pay reward and return deposit
        }
        _trackOfflineWorkers();
    }

    function gatheringWorkersResponse(bool _flag)
    onlyActiveWorkers
//    requireState(GatheringWorkers)
    external {
        uint256 workerIndex;
        (,workerIndex) = _getWorkerFromSender();
        require(workerIndex != uint256(-1));
        _processAcceptanceResponse(_flag);
    }

    //implemented
    function dataValidationResponse(DataValidationResponse _response)
    onlyActiveWorkers
//    requireState(DataValidation)
    external {
        /// @todo implement full (data arbitration alorithm)[https://github.com/pandoraboxchain/techspecs/wiki/Data-inconsistency-arbitration]
        if (_response == DataValidationResponse.Invalid) {
            _transitionToState(InvalidData);
            return;
        }
        _processValidationResponse(_response == DataValidationResponse.Accept);
    }

    function commitProgress(uint8 _percent)
    external {
        uint256 workerIndex;
        (,workerIndex) = _getWorkerFromSender();
        require(workerIndex != uint256(-1));

        responseTimestamps[workerIndex] = block.timestamp;
        emit CognitionProgressed(_percent);
    }

    ///@notice every worker call this function, with their work results
    ///Job is considered finalized, when every worker complete it. The last one, who submits results should check the
    ///Pandora job queue, in case it doesn't do this - it couldn't switch to idle state.
    function completeWork(bytes _ipfsResults)
//    requireState(Cognition)
    external
    returns(bool isFinalized){
        uint256 workerIndex;
        (,workerIndex) = _getWorkerFromSender();
        require(workerIndex != uint256(-1)); //worker is active

        ipfsResults[workerIndex] = _ipfsResults;
        completionFlags[workerIndex] = true;
        responseTimestamps[workerIndex] = block.timestamp;
        _trackOfflineWorkers();
        if (isAllWorkersCompleted()) {
            _transitionToState(Completed);
            isFinalized = true;
            finalizedWorker = IWorkerNode(msg.sender);
        }
    }

    function activeWorkersCount()
    view
    external
    returns(uint256) {
        return activeWorkers.length;
    }

    function didWorkerCompute(
        uint no
    )
    requireState(Cognition) //worker could compute only in Cognition job state
    view
    external
    returns(bool)
    {
        return acceptionFlags[no];
    }

    function unlockFinalizedWorker()
    onlyPandora
    external
    {
        finalizedWorker.unlockFinalizedState();
        finalizedWorker = IWorkerNode(0);
    }

    /**
     * ## State Machine implementation
     */

    modifier requireActiveStates() {
        require(
            stateMachine.currentState == GatheringWorkers ||
            stateMachine.currentState == DataValidation ||
            stateMachine.currentState == Cognition
        );
        _;
    }

    function _initStateMachine() internal {
        // Creating table of possible state transitions
        mapping(uint8 => uint8[]) transitions = stateMachine.transitionTable;
        transitions[Uninitialized] = [GatheringWorkers];
        transitions[GatheringWorkers] = [InsufficientWorkers, DataValidation];
        transitions[DataValidation] = [InvalidData, Cognition, InsufficientWorkers];
        transitions[Cognition] = [Completed, PartialResult];

        // Initializing state machine via base contract code
        super._initStateMachine();

        // Going into initial state (Uninitialized)
        stateMachine.currentState = Uninitialized;
    }

    function _fireStateEvent() internal {
        if (currentState() == InsufficientWorkers) {
            emit WorkersNotFound();
            _cleanStorage(); //todo refactor
        } else if (currentState() == DataValidation) {
            emit DataValidationStarted();
        } else if (currentState() == InvalidData) {
            emit DataValidationFailed();
            _cleanStorage(); //todo refactor
        } else if (currentState() == Cognition) {
            emit CognitionStarted();
        } else if (currentState() == PartialResult) {
            emit CognitionCompleted(true);
            pandora.finishCognitiveJob();
        } else if (currentState() == Completed) {
            emit CognitionCompleted(false);
            pandora.finishCognitiveJob();
        }
    }

    function _transitionToState(uint8 _newState) private requireAllowedTransition(_newState)  {
        transitionToState(_newState);
    }

    event WorkersUpdated();
    event WorkersNotFound();
    event DataValidationStarted();
    event DataValidationFailed();
    event CognitionStarted();
    event CognitionProgressed(uint8 precent);
    event CognitionCompleted(bool partialResult);
}
