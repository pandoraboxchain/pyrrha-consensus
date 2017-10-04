pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './Pandora.sol';
import './CognitiveJob.sol';
import {StateMachineLib as SM} from './libraries/StateMachineLib.sol';

/**
 * @title Worker Node Smart Contract
 * @author "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>
 *
 * @dev # Worker Node Smart Contract
 *
 * Worker node contract accumulates funds/payments for performed cognitive work and contains inalienable reputation.
 * Note: In Pyrrha there is no mining. In the following versions all mined coins will be also assigned to the
 * `WorkerNode` contract
 *
 * Worker node acts as a state machine and each its function can be evoked only in some certain states. That's
 * why each function must have state machine-controlled function modifiers. Contract state is managed by
 * - Worker node code (second level of consensus)
 * - Main Pandora contract [Pandora.sol]
 * - Worker node contract itself
 */

contract WorkerNode is Destructible /* final */ {
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

    // Initial and base state
    uint8 public constant Idle = 1;

    uint8 public constant Assigned = 2;

    // When node goes offline it can mark itself as offline to prevent penalties.
    // If node is not responding to Pandora events and does not submit updates on the cognitive work in time
    // then it will be penaltied and put into `Offline` state
    uint8 public constant Offline = 3;

    uint8 public constant InsufficientStake = 4;

    // Intermediary state preventing from performing any type of work during penalty process
    uint8 public constant UnderPenalty = 5;

    // Worker node downloads and validates source data for correctness and consistency
    uint8 public constant ValidatingData = 6;

    // State when actual worker node performs cognitive job
    uint8 public constant Computing = 7;

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
    }

    modifier transitionThroughState(
        uint8 _transitionState
    ) {
        var initialState = stateMachine.currentState;
        stateMachine.transitionThroughState(_transitionState);
        _;
        stateMachine.currentState = initialState;
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
        transitions[Uninitialized] = [Idle, Offline, InsufficientStake];
        transitions[Offline] = [InsufficientStake, Idle];
        transitions[Idle] = [Offline, InsufficientStake, UnderPenalty, Assigned];
        transitions[Assigned] = [Offline, InsufficientStake, UnderPenalty, ValidatingData];
        transitions[UnderPenalty] = [InsufficientStake, Idle];
        transitions[ValidatingData] = [Idle, UnderPenalty, Computing];
        transitions[Computing] = [UnderPenalty, Idle];
        stateMachine.initStateMachine();
        stateMachine.currentState = Uninitialized;
    }

    /**
     * ## Main implementation
     */

    Pandora public pandora;
    CognitiveJob public activeJob;
    uint256 public reputation;

    function WorkerNode (Pandora _pandora) {
        //require(_pandora != address(0));

        pandora = _pandora;
        reputation = 0;
        activeJob = CognitiveJob(0);
        _initStateMachine();
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
    }

    modifier onlyCognitiveJob() {
        CognitiveJob sender = CognitiveJob(msg.sender);
        require(pandora == sender.pandora());
        require(pandora.activeJobs(sender) == sender);
        _;
    }

    function linkPandora(Pandora _pandora) external onlyOwner requireState(Uninitialized) transitionToState(Offline) {
        require(pandora == address(0));
        require(_pandora != address(0));
        pandora = _pandora;
    }

    function alive() external /* @fixme onlyOwner */ requireState(Offline) transitionToState(Idle) {
        // Nothing to do here
    }

    function acceptAssignment() external /* @fixme onlyOwner */ requireState(Assigned) transitionToState(ValidatingData) {
        require(activeJob != CognitiveJob(0));
        activeJob.gatheringWorkersResponse(true);
    }

    function declineAssignment() external onlyOwner requireState(Assigned) transitionToState(Idle) {
        require(activeJob != CognitiveJob(0));
        activeJob.gatheringWorkersResponse(false);
    }

    function assignJob(CognitiveJob job) external onlyCognitiveJob transitionToState(Assigned) {
        activeJob = job;
    }

    function increaseReputation() external onlyPandora {
        reputation++;
    }

    function decreaseReputation() external onlyPandora transitionThroughState(UnderPenalty) {
        if (reputation == 0) {
            destroyAndSend(pandora);
        } else {
            reputation--;
        }
    }

    function resetReputation(
        // No arguments
    ) external // Can't be called internally
        // Only Pandora contract can put such penalty
        onlyPandora
        // State machine processes
        transitionThroughState(UnderPenalty)
    {
        reputation = 0;
    }

    function maxPenalty(
        // No arguments
    ) external // Can't be called internally
        // Only Pandora contract can put such penalty
        onlyPandora
        // State machine processes
        transitionThroughState(UnderPenalty)
    {
        reputation = 0;
    }

    /// @notice For internal use by main Pandora contract
    /// @dev Zeroes reputation and destroys node
    function deathPenalty(
        // No arguments
    ) external // Can't be called internally
        // Only Pandora contract can put such penalty
        onlyPandora
        // State machine processes
        transitionThroughState(UnderPenalty)
    {
        // First, we put remove all reputation
        reputation = 0;

        // Use function from OpenZepplin Destructible contract
        destroyAndSend(pandora);
    }

    /// @notice Withdraws full balance to the owner account. Can be called only by the owner of the contract.
    function withdrawBalance(
        // No arguments
    ) external // Can't be called internally
        onlyOwner // Can be called only by the owner
        requireStates2(Idle, Offline)
    {
        /// @todo Handle stakes etc
        owner.transfer(this.balance);
    }
}
