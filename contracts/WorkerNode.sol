pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './Pandora.sol';

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

    /**
     * ## State machine
     */

    enum State {
        // Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
        // to indicate that contract had being destroyed
        Destroyed,

        // Initial and base state
        Idle,

        // State when actual worker node performs cognitive job
        Computing,

        // When node goes offline it can mark itself as offline to prevent penalties.
        // If node is not responding to Pandora events and does not submit updates on the cognitive work in time
        // then it will be penaltied and put into `Offline` state
        Offline,

        // Intermediary state preventing from performing any type of work during penalty process
        UnderPenalty
    }

    /// @dev Current state of worker node (as a state machine)
    State public currentState;

    modifier onlyIdle() {
        assert(currentState == State.Idle);
        _;
    }

    modifier onlyComputing() {
        assert(currentState == State.Computing);
        _;
    }

    modifier putUnderPenalty() {
        assert(currentState != State.Computing);
        State prevState = currentState;
        currentState = State.UnderPenalty;
        _;
        currentState = prevState;
    }

    function updateState(
        State _newState
    ) external
        onlyPandora
    {
        currentState = _newState;
    }

    function goOffline(
        // No arguments
    ) external
        onlyOwner
        onlyIdle
    {
        currentState = State.Offline;
    }

    function backOnline(
        // No arguments
    ) external
        onlyOwner
    {
        require(currentState == State.Offline);

        currentState = State.Idle;
    }

    /**
     * ## Main implementation
     */

    Pandora internal pandora;

    uint256 public reputation;

    function WorkerNode (Pandora _pandora) {
        pandora = _pandora;
        reputation = 0;

        currentState = State.Idle;
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
    }

    function increaseReputation() external onlyPandora {
        reputation++;
    }

    function decreaseReputation() external onlyPandora putUnderPenalty {
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
        putUnderPenalty
    {
        reputation = 0;
    }

    function maxPenalty(
        // No arguments
    ) external // Can't be called internally
        // Only Pandora contract can put such penalty
        onlyPandora
        // State machine processes
        putUnderPenalty
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
        putUnderPenalty
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
