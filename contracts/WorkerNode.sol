pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/ownership/Destructible.sol';
import './Pandora.sol';

/*

 */

contract WorkerNode is Destructible {

    /*
     * ## State machine
     */

    enum State {
        // Since destroyself zeroes values of all variables, we need the first state (corresponding to zero)
        // to indicate that contract had being destroyed
        Destroyed,
        Idle,
        Computing,
        Offline,
        UnderPenalty
    }

    State public currentState;

    modifier onlyIdle() {
        assert(currentState == State.Idle);
        _;
    }

    modifier onlyComputing() {
        assert(currentState == State.Computing);
        _;
    }

    modifier putsUnderPenalty() {
        assert(currentState != Computing);
        State prevState = currentState;
        currentState = UnderPenalty;
        _;
        currentState = prevState;
    }

    function updateState(State _newState) external onlyPandora {
        currentState = _newState;
    }

    function nextState() {

    }

    /*
     * ## Main implementation
     */

    Pandora private pandora;

    uint256 public reputation;

    function WorkerNode (Pandora _pandora) {
        pandora = _pandora;
        currentState = State.Idle;
        reputation = 0;
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
    }

    function increaseReputation() external onlyPandora {
        reputation++;
    }

    function decreaseReputation() external onlyPandora {
        if (reputation == 0) {
            destroyAndSend(pandora);
        } else {
            reputation--;
        }
    }

    function resetReputation() external onlyPandora {
        reputation = 0;
    }

    function maxPenalty() external onlyPandora {
        reputation = 0;
    }

    /**
     * @notice For internal use by main Pandora contract
     * @dev
     */
    function deathPenalty(
        // No arguments
    ) external // Can't be called internally
        // Only Pandora contract can put such penalty
        onlyPandora
        // State machine processes
        putsUnderPenalty
    {
        // First, we put maximum penalty on reputation
        maxPenalty();

        // Instead of destroying the node in Pyrrha we just transfer funds to the Pandora main contract (controlled by
        // Pandora Foundation), since we have pre-defined worker node whitelist and would not be able to replace the
        // worker with a new one. This will prevent DoS attack, when malicious agents can order some simple
        // computations, give negative feedback and kill all worker nodes one by one
        // destroyAndSend(pandora);
    }
}
