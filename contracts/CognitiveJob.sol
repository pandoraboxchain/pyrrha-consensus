pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './Kernel.sol';
import './Dataset.sol';
import './Pandora.sol';
import './WorkerNode.sol';
import {StateMachineLib as SM} from './libraries/StateMachineLib.sol';

/*

 */

contract CognitiveJob is Destructible /* final */ {
    /**
     * ## State Machine implementation
     */

    using SM for SM.StateMachine;

    // Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
    // to indicate that contract had being destroyed
    uint8 public constant Destroyed = 0xFF;

    // Reserved system state not participating in transition table. Since contract creation all variables are
    // initialized to zero and contract state will be zero until it will be initialized with some definite state
    uint8 public constant Uninitialized = 0;

    uint8 public constant GatheringWorkers = 1;

    uint8 public constant InsufficientWorkers = 2;

    uint8 public constant DataValidation = 3;

    uint8 public constant InvalidData = 4;

    uint8 public constant Cognition = 5;

    uint8 public constant PartialResult = 6;

    uint8 public constant Completed = 7;

    SM.StateMachine internal stateMachine;

    function currentState() public constant returns (uint8) {
        return stateMachine.currentState;
    }

    modifier transitionToState(
        uint8 _newState
    ) {
        stateMachine.transitionToState(_newState);
        _;
        stateMachine.currentState = _newState;
        _fireStateEvent();
    }

    modifier requireState(
        uint8 _requiredState
    ) {
        require(stateMachine.currentState == _requiredState);
        _;
    }

    modifier requireStates2(
        uint8 _requiredState1,
        uint8 _requiredState2
    ) {
        stateMachine.requireStates2(_requiredState1, _requiredState2);
        _;
    }

    modifier requireActiveStates() {
        require(stateMachine.currentState == GatheringWorkers);
        require(stateMachine.currentState == DataValidation);
        require(stateMachine.currentState == Cognition);
        _;
    }

    function _initStateMachine() private {
        var transitions = stateMachine.transitionTable;
        transitions[GatheringWorkers] = [InsufficientWorkers, DataValidation];
        transitions[DataValidation] = [InvalidData, Cognition, InsufficientWorkers];
        transitions[Cognition] = [Completed, PartialResult, InsufficientWorkers];
        stateMachine.initStateMachine();
    }

    function _fireStateEvent() constant private {
        if (currentState() == InsufficientWorkers) {
            WorkersNotFound();
        } else if (currentState() == DataValidation) {
            DataValidationStarted();
        } else if (currentState() == InvalidData) {
            DataValidationFailed();
        } else if (currentState() == Cognition) {
            CognitionStarted();
        } else if (currentState() == PartialResult) {
            CognitionCompleted(true);
        } else if (currentState() == Completed) {
            CognitionCompleted(false);
        }
    }

    /**
     * ## Main functionality
     */

    uint internal constant WORKER_TIMEOUT = 10 minutes;

    Pandora public pandora;
    Kernel public kernel;
    Dataset public dataset;
    WorkerNode[] public activeWorkers;
    WorkerNode[] public workersPool;
    uint[] internal workersResponses;

    uint8 public progress = 0;
    bytes public ipfsResults;

    event WorkersUpdated();

    event WorkersNotFound();
    event DataValidationStarted();
    event DataValidationFailed();
    event CognitionStarted();
    event CognitionProgressed(uint8 precent);
    event CognitionCompleted(bool partialResult);

    function CognitiveJob(
        Pandora _pandora,
        Kernel _kernel,
        Dataset _dataset,
        WorkerNode[] _workersPool
    ) {
        var batches = _dataset.batchesCount();
        require(batches != 0);
        require(workersPool.length >= batches);
        require(_pandora != address(0));
        require(_kernel != address(0));
        require(_dataset != address(0));

        pandora = _pandora;
        kernel = _kernel;
        dataset = _dataset;

        // Select initial worker
        activeWorkers = new WorkerNode[](batches);
        workersResponses = new uint[](batches);
        for (uint8 batch = 0; batch < batches; batch++) {
            workersResponses[batch] = 0; // no response given yet
            activeWorkers[batch] = _workersPool[batch];
            activeWorkers[batch].assignJob();
        }
        for (uint16 pool = batch; pool < _workersPool.length; pool++) {
            workersPool[pool - batch] = _workersPool[pool];
        }

        _initStateMachine();

        WorkersUpdated();
    }

    modifier onlyActiveWorkers() {
        WorkerNode workerNode;
        (workerNode,) = _getWorkerFromSender();
        require(workerNode != WorkerNode(0));
        require(msg.sender == address(workerNode));
        require(tx.origin == workerNode.owner());
        _;
    }

    modifier checkReadiness() {
        for (uint256 no = 0; no < workersResponses.length; no++) {
            if (workersResponses[no] == false) {
                return;
            }
        }
        _;
    }

    function _getWorkerIndex(WorkerNode _worker) private constant returns (uint256) {
        for (uint256 index = 0; index < activeWorkers.length; index++) {
            if (msg.sender == address(activeWorkers[index])) {
                return index;
            }
        }
        return uint256(-1);
    }

    function _getWorkerFromSender() private constant returns (WorkerNode o_workerNode, uint256 o_workerIndex) {
        o_workerIndex = _getWorkerIndex(WorkerNode(msg.sender));
        if (o_workerIndex > activeWorkers.length) {
            return (WorkerNode(0), uint256(-1));
        }
        o_workerNode = activeWorkers[o_workerIndex];
    }

    function _replaceWorker(uint256 workerIndex) private requireStates2(DataValidation, Cognition) {
        WorkerNode replacementWorker;
        do {
            if (workersPool.length == 0) {
                _insufficientWorkers();
                return;
            }
            workersPool[workersPool.length - 1];
            workersPool.length = workersPool.length - 1;
        } while (replacementWorker.currentState() != replacementWorker.Idle());

        workersResponses[workerIndex] = 0; // no response is given from the new worker yet
        activeWorkers[workerIndex] = replacementWorker;
        replacementWorker.assignJob();
        WorkersUpdated();
    }

    function _insufficientWorkers() private requireState(GatheringWorkers) transitionToState(InsufficientWorkers) {
        activeWorkers.length = 0;
    }

    function _trackOfflineWorkers() private requireActiveStates {
        for (uint256 no = 0; no < workersResponses.length; no++) {
            if (workersResponses[no] - block.timestamp > WORKER_TIMEOUT) {
                WorkerNode guiltyWorker = activeWorkers[no];
                Pandora.WorkersPenalties penalty;
                if (stateMachine.currentState == GatheringWorkers) {
                    penalty = Pandora.WorkersPenalties.OfflineWhileGathering;
                } else if (stateMachine.currentState == DataValidation) {
                    penalty = Pandora.WorkersPenalties.OfflineWhileDataValidation;
                } else if (stateMachine.currentState == Cognition) {
                    penalty = Pandora.WorkersPenalties.OfflineWhileCognition;
                } else {
                    revert(); // This should not happen due to requireActiveStates function modifier
                }
                pandora.penaltizeWorker(guiltyWorker, penalty);
                _replaceWorker(no);
            }
        }
    }

    function _transitionIfReady(uint8 _newState) private checkReadiness transitionToState(_newState) {
        for (uint256 no = 0; no < workersResponses.length; no++) {
            workersResponses[no] = 0; // no response or update is given
        }
    }

    /// @dev Main entry point for
    /// (Witnessing worker nodes going offline)[https://github.com/pandoraboxchain/techspecs/wiki/Witnessing-worker-nodes-going-offline]
    /// workflow
    function reportOfflineWorker(WorkerNode _reportedWorker) payable external requireActiveStates {
        /// @todo accept deposit
        uint256 reportedIndex = _getWorkerIndex(_reportedWorker);
        if (workersResponses[reportedIndex] - block.timestamp > WORKER_TIMEOUT) {
            /// @todo pay reward and return deposit
        }
        _trackOfflineWorkers();
    }

    function gatheringWorkersResponse(bool _acceptanceFlag) external onlyActiveWorkers requireState(GatheringWorkers) {
        var (reportingWorker, workerIndex) = _getWorkerFromSender();
        if (_acceptanceFlag == false) {
            _replaceWorker(workerIndex);
            pandora.penaltizeWorker(reportingWorker, Pandora.WorkersPenalties.OfflineWhileGathering);
        } else {
            workersResponses[workerIndex] = block.timestamp;
            _trackOfflineWorkers();
            _transitionIfReady(DataValidation);
        }
    }

    enum DataValidationResponse {
        Accept, Decline, Invalid
    }
    function dataValidationResponse(DataValidationResponse _response) onlyActiveWorkers external {
        /*
        var (reportingWorker, workerIndex) = _getWorkerFromSender();
        if (_response == DataValidationResponse.Decline) {
            _replaceWorker(workerIndex);
        } else {
            workersResponses[workerIndex] = true;
            _transitionIfReady(DataValidation);
        }
        */
    }

    function commitProgress(uint8 percent) onlyActiveWorkers external {
        //CognitionProgressed(percent);
    }

    function completeWork(bytes _ipfsResults) onlyActiveWorkers external {
        //completed = true;
        //pandora.finishCognitiveJob(this);

        //JobCompleted();
    }

    function activeWorkersCount() constant external returns(uint256) {
        return activeWorkers.length;
    }
}
