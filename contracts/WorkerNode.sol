pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './Pandora.sol';
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

contract WorkerNode is Destructible {
    using SM for SM.StateMachine;

    // Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
    // to indicate that contract had being destroyed
    uint8 public constant Destroyed = 0xFF;

    // Initial and base state
    uint8 public constant Idle = 1;

    // When node goes offline it can mark itself as offline to prevent penalties.
    // If node is not responding to Pandora events and does not submit updates on the cognitive work in time
    // then it will be penaltied and put into `Offline` state
    uint8 public constant Offline = 2;

    uint8 public constant InsufficientStake = 3;

    // Intermediary state preventing from performing any type of work during penalty process
    uint8 public constant UnderPenalty = 4;

    // Worker node downloads and validates source data for correctness and consistency
    uint8 public constant ValidatingData = 5;

    // State when actual worker node performs cognitive job
    uint8 public constant Computing = 6;

    SM.StateMachine internal stateMachine;

    function currentState() public returns (uint8) {
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

    function initStateMachine() {
        var transitions = stateMachine.transitionTable;
        transitions[Idle] = [Offline, InsufficientStake, UnderPenalty, ValidatingData];
        /*
        uint8(State.Offline) => State.InsufficientStake,
        State.Offline, State.Idle,

        State.InsufficientStake, State.Offline,
        State.InsufficientStake, State.UnderPenalty,
        State.InsufficientStake, State.Idle,

        State.Idle, State.Offline,
        State.Idle, State.UnderPenalty,
        State.Idle, State.ValidatingData,
        State.Idle, State.InsufficientStake,

        State.UnderPenalty, State.InsufficientStake,
        State.UnderPenalty, State.Idle,

        State.ValidatingData, State.InsufficientStake,
        State.ValidatingData, State.Idle,
        State.ValidatingData, State.UnderPenalty,
        State.ValidatingData, State.Computing,

        State.Computing, State.InsufficientStake,
        State.Computing, State.UnderPenalty,
        State.Computing, State.Idle
        */
        stateMachine.initStateMachine();
    }

    /**
     * ## Main implementation
     */

    Pandora internal pandora;

    uint256 public reputation;

    function WorkerNode (Pandora _pandora) {
        pandora = _pandora;
        reputation = 0;
        stateMachine.initStateMachine();
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
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
    //    putUnderPenalty
    {
        reputation = 0;
    }

    function maxPenalty(
        // No arguments
    ) external // Can't be called internally
        // Only Pandora contract can put such penalty
        onlyPandora
        // State machine processes
    //    putUnderPenalty
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
    //    putUnderPenalty
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
    {
        /// @todo Handle stakes etc
        owner.transfer(this.balance);
    }
}
