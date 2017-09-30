pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './Pandora.sol';
import './WorkerStateMachine.sol';

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
    using WorkerStateMachine for WorkerStateMachine.StateMachine;

    WorkerStateMachine.StateMachine internal stateMachine;

    function currentState() public returns (WorkerStateMachine.State) {
        return stateMachine.currentState;
    }

    modifier transitionToState(
        WorkerStateMachine.State _newState
    ) {
        stateMachine.transitionToState(_newState);
        _;
        stateMachine.currentState = _newState;
    }

    modifier transitionThroughState(
        WorkerStateMachine.State _transitionState
    ) {
        WorkerStateMachine.State initialState = stateMachine.currentState;

        stateMachine.transitionThroughState(_transitionState);
        stateMachine.currentState = _transitionState;
        _;
        stateMachine.currentState = initialState;
    }

    modifier requireState(
        WorkerStateMachine.State _requiredState
    ) {
        require(stateMachine.currentState == _requiredState);
        _;
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

    function decreaseReputation() external onlyPandora transitionThroughState(WorkerStateMachine.State.UnderPenalty) {
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
