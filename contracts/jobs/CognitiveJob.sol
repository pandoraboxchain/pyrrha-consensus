pragma solidity ^0.4.23;

import "../libraries/StateMachine.sol";
import "./IComputingJob.sol";

/*

 */

contract CognitiveJob is IComputingJob, StateMachine /* final */ {

    /**
     * ## Main functionality
     */

    uint internal constant WORKER_TIMEOUT = 30 minutes;

    IPandora public pandora;
    IKernel public kernel;
    IDataset public dataset;
    uint256 public batches;
    uint256 public complexity; //todo find better name
    bytes32 public description;
    IWorkerNode[] public activeWorkers;
    IWorkerNode[] public workersPool;
    bytes[] public ipfsResults;

    uint256[] private responseTimestamps;
    bool[] private acceptionFlags;
    bool[] private validationFlags;
    bool[] private completionFlags;

    event WorkersUpdated();
    event WorkersNotFound();
    event DataValidationStarted();
    event DataValidationFailed();
    event CognitionStarted();
    event CognitionProgressed(uint8 precent);
    event CognitionCompleted(bool partialResult);

    constructor(
        IPandora _pandora,
        IKernel _kernel,
        IDataset _dataset,
        IWorkerNode[] _workersPool,
        uint256 _complexity,
        bytes32 _description
    )
    public {
        batches = _dataset.batchesCount();
        require(batches > 0);
        require(_workersPool.length >= batches);
        require(_pandora != address(0));
        require(_kernel != address(0));
        require(_dataset != address(0));

        pandora = _pandora;
        kernel = _kernel;
        dataset = _dataset;
        workersPool = _workersPool;
        complexity = _complexity;
        description = _description;
        _initStateMachine();
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
    }

    modifier onlyActiveWorkers() {
        IWorkerNode workerNode;
        (workerNode,) = _getWorkerFromSender();
        require(workerNode != IWorkerNode(0));
        require(msg.sender == address(workerNode));
        require(tx.origin == workerNode.owner());
        _;
    }

    function isAllWorkersAccepted() returns(bool accepted) {
        accepted = true;
        for (uint256 i = 0; i < acceptionFlags.length; i++) {
            if (acceptionFlags[i] != true) {
                accepted = false;
            }
        }
    }

    function isAllWorkersValidated() returns(bool validated) {
        validated = true;
        for (uint256 i = 0; i < validationFlags.length; i++) {
            if (validationFlags[i] != true) {
                validated = false;
            }
        }
    }

    function isAllWorkersCompleted() returns(bool completed) {
        completed = true;
        for (uint256 i = 0; i < completionFlags.length; i++) {
            if (completionFlags[i] != true) {
                completed = false;
            }
        }
    }

    function _getWorkerIndex(IWorkerNode _worker) private view returns (uint256) {
        for (uint256 index = 0; index < activeWorkers.length; index++) {
            if (_worker == address(activeWorkers[index])) {
                return index;
            }
        }
        return uint256(-1);
    }

    function ipfsResultsCount() public view returns (uint256 count) {
        count = ipfsResults.length;
    }

    function _getWorkerFromSender() private view returns (IWorkerNode o_workerNode, uint256 o_workerIndex) {
        o_workerIndex = _getWorkerIndex(IWorkerNode(msg.sender));
        if (o_workerIndex > activeWorkers.length) {
            return (IWorkerNode(0), uint256(-1));
        }
        o_workerNode = activeWorkers[o_workerIndex];
    }

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

    function _cleanStorage() private {
        workersPool.length = 0;
        activeWorkers.length = 0;
        ipfsResults.length = 0;
        acceptionFlags.length = 0;
        responseTimestamps.length = 0;
    }

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

    function _transitionToState(uint8 _newState) private requireAllowedTransition(_newState)  {
        transitionToState(_newState);
    }

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
            if (isAllWorkersAccepted()) {
                updateResponses();
                _transitionToState(PartialResult);
            }
        }
    }

    ///@dev Reset all response flags after gathering and cognition start
    function updateResponses() private {
        for (uint256 i = 0; i < activeWorkers.length; i++) {
            responseTimestamps[i] = block.timestamp;
        }
    }

    function initialize()
    external
// onlyPandora
    requireState(Uninitialized)
    {
        // Select initial worker
        activeWorkers = new IWorkerNode[](batches);
        responseTimestamps = new uint[](batches);
        acceptionFlags = new bool[](batches);
        validationFlags = new bool[](batches);
        completionFlags = new bool[](batches);
        ipfsResults = new bytes[](batches);
        for (uint8 batch = 0; batch < batches; batch++) {
            acceptionFlags[batch] = false; // no response is given yet
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
        _processAcceptanceResponse(_flag);
    }

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
    onlyActiveWorkers
    external {
        uint256 workerIndex;
        (,workerIndex) = _getWorkerFromSender();
        responseTimestamps[workerIndex] = block.timestamp;
        emit CognitionProgressed(_percent);
    }

    function completeWork(bytes _ipfsResults)
    onlyActiveWorkers
//    requireState(Cognition)
    external {
        uint256 workerIndex;
        (,workerIndex) = _getWorkerFromSender();
        ipfsResults[workerIndex] = _ipfsResults;
        acceptionFlags[workerIndex] = true;
        completionFlags[workerIndex] = true;
        responseTimestamps[workerIndex] = block.timestamp;
        _trackOfflineWorkers();
        if (isAllWorkersCompleted()) {
            _transitionToState(Completed);
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
            _cleanStorage();
        } else if (currentState() == DataValidation) {
            emit DataValidationStarted();
        } else if (currentState() == InvalidData) {
            emit DataValidationFailed();
            _cleanStorage();
        } else if (currentState() == Cognition) {
            emit CognitionStarted();
        } else if (currentState() == PartialResult) {
            emit CognitionCompleted(true);
            pandora.finishCognitiveJob();
            //todo separate finishing in cognitiveJobManager
        } else if (currentState() == Completed) {
            emit CognitionCompleted(false);
            pandora.finishCognitiveJob();
        }
    }
}
