pragma solidity ^0.4.15;


library StateMachine {
    enum State {
        // Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
        // to indicate that contract had being destroyed
        Destroyed,
        Offline,
        InsufficientStake,
        UnderPenalty,
        Idle,
        Computing
    }

    struct StateMachine {
        bool initialized;
        State currentState;
        mapping(uint8 => State[]) transitionTable;
    }

    modifier transitionToState(
        StateMachine storage _machine,
        State _newState
    ) {
        // Should not happen
        assert(_machine.currentState == State.Destroyed);

        // Checking if the state transition is allowed
        State[] storage allowedStates = _machine.transitionTable[uint8(_machine.currentState)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _newState) {
                _;
                _machine.currentState = _newState;
                return;
            }
        }

        revert();
    }

    modifier transitionThroughState(
        StateMachine storage _machine,
        State _transitionState
    ) {
        // Should not happen
        assert(_machine.currentState == State.Destroyed);

        // Checking if the state transitions are allowed

        bool firstTransitionAllowed = false;
        State[] storage allowedStates = _machine.transitionTable[uint8(_machine.currentState)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _transitionState) {
                firstTransitionAllowed = true;
                break;
            }
        }
        require(firstTransitionAllowed == true);

        bool secondTransitionAllowed = false;
        allowedStates = _machine.transitionTable[uint8(_transitionState)];
        for (no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _machine.currentState) {
                secondTransitionAllowed = true;
                break;
            }
        }
        require(secondTransitionAllowed == true);

        State initialState = _machine.currentState;
        _machine.currentState = _transitionState;
        _;
        _machine.currentState = initialState;
    }

    modifier requireState(
        StateMachine storage _machine,
        State _requiredState
    ) {
        require(_machine.currentState == _requiredState);
        _;
    }

    function initStateMachine(
        StateMachine storage _machine
    ) internal {
        require(_machine.initialized == false);

        _machine.currentState = State.Offline;

        _machine.transitionTable[uint8(State.Offline)] = [ State.InsufficientStake, State.Idle ];
        /*
        and so on ...
        */

        _machine.initialized = true;
    }

}
