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

    uint8 public constant Validation = 3;

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

    function _initStateMachine() private {
        var transitions = stateMachine.transitionTable;
        transitions[GatheringWorkers] = [InsufficientWorkers, Validation];
        transitions[Validation] = [InvalidData, Cognition, InsufficientWorkers];
        transitions[Cognition] = [Completed, PartialResult, InsufficientWorkers];
        stateMachine.initStateMachine();
    }

    function _fireStateEvent() constant private {
        if (currentState() == InsufficientWorkers) {
            WorkersNotFound();
        } else if (currentState() == Validation) {
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

    Pandora public pandora;
    Kernel public kernel;
    Dataset public dataset;
    WorkerNode[] public activeWorkers;
    WorkerNode[] public workersPool;
    bool[] internal workersResponses;

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
        workersResponses = new bool[](batches);
        for (uint8 batch = 0; batch < batches; batch++) {
            workersResponses[batch] = false;
            activeWorkers[batch] = _workersPool[batch];
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

    function _getWorkerFromSender() private constant returns (WorkerNode o_workerNode, uint256 o_workerIndex) {
        o_workerNode = WorkerNode(0);
        for (o_workerIndex = 0; o_workerIndex < activeWorkers.length; o_workerIndex++) {
            o_workerNode = activeWorkers[o_workerIndex];
            if (msg.sender == address(o_workerNode)) {
                return;
            }
        }
    }

    function _replaceWorker(uint256 workerIndex) private requireStates2(Validation, Cognition) {
        WorkerNode replacementWorker;
        do {
            if (workersPool.length == 0) {
                _insufficientWorkers();
                return;
            }
            workersPool[workersPool.length - 1];
            workersPool.length = workersPool.length - 1;
        } while (replacementWorker.currentState() != replacementWorker.Idle());

        workersResponses[workerIndex] = false;
        activeWorkers[workerIndex] = replacementWorker;
        WorkersUpdated();
    }

    function _insufficientWorkers() private requireState(GatheringWorkers) transitionToState(InsufficientWorkers) {
        activeWorkers.length = 0;
    }


    function _transitionIfReady(uint8 _newState) private checkReadiness transitionToState(_newState) {
        for (uint256 no = 0; no < workersResponses.length; no++) {
            workersResponses[no] = false;
        }
    }


    function gatheringWorkersResponse(bool _acceptanceFlag) external onlyActiveWorkers requireState(GatheringWorkers) {
        var (reportingWorker, workerIndex) = _getWorkerFromSender();
        if (_acceptanceFlag == false) {
            _replaceWorker(workerIndex);
        } else {
            workersResponses[workerIndex] = true;
            _transitionIfReady(Validation);
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
            _transitionIfReady(Validation);
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
}
