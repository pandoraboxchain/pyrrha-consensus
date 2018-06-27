pragma solidity ^0.4.23;

import "./IStateMachine.sol";
import "../lifecycle/OnlyOnce.sol";
import {StateMachineLib as SM} from "../libraries/StateMachineLib.sol";

contract StateMachine is IStateMachine, OnlyOnce {

    // todo exp branch replace statemachine lib with modifiers for each state -- and check for gas

    /**
     * ## State Machine implementation
     */

    using SM for SM.StateMachine;

    /// @dev Structure holding the state of the contract
    SM.StateMachine internal stateMachine;

    event StateChanged(uint8 oldState, uint8 newState);

    modifier requireAllowedTransition(uint8 _newState) {
        stateMachine.isTransitionAllowed(_newState);
        _;
    }

    /// @notice Returns current state of the contract state machine
    /// @dev Shortcut to receive current state from external contracts
    function currentState() public view returns (
        uint8 /// Current state
    ) {
        return stateMachine.currentState;
    }

    /// @dev State transition function
    function transitionToState(
        uint8 _newState /// New state to transition into
    ) public {
        uint8 oldState = stateMachine.currentState;
        stateMachine.currentState = _newState;
        emit StateChanged(oldState, stateMachine.currentState);
        _fireStateEvent();
    }

//
//    /// @dev State transition function from StateMachineLib put into modifier form.
//    /// **Important:** state transition happens _before_ the main code of the calling function, and _after_ the
//    /// execution contract is returned to the original state.
//    modifier transitionThroughState(
//        uint8 _transitionState /// Intermediary state to transition through
//    ) {
//        uint8 initialState = stateMachine.currentState;
//        stateMachine.transitionThroughState(_transitionState);
//        emit StateChanged(initialState, stateMachine.currentState);
//        _fireStateEvent();
//        _;
//        stateMachine.currentState = initialState;
//        emit StateChanged(_transitionState, stateMachine.currentState);
//        _fireStateEvent();
//    }

    /// @dev Modifier requiring contract to be present in certain state; otherwise the exception is generated and the
    /// function does not execute
    modifier requireState(
        uint8 _requiredState /// Required state
    ) {
        require(stateMachine.currentState == _requiredState);
        _;
    }

    /// @dev Modifier requiring contract to be present in one of two certain states; otherwise an exception is
    /// generated and the function does not execute
    modifier requireStates2(
        uint8 _requiredState1, /// Required state, option 1
        uint8 _requiredState2 /// Required state, option 2
    ) {
        stateMachine.requireStates2(_requiredState1, _requiredState2);
        _;
    }

    /// @dev Private method initializing state machine. Must be called only once from the contract constructor
    function _initStateMachine() internal onlyOnce("_initStateMachine") {
        // Initializing state machine via library code
        stateMachine.initStateMachine();
    }

    /// @dev Hook for inherited contracts to fire contract-specific state change events
    function _fireStateEvent() internal {
        // Implemented by child contracts
    }
}
