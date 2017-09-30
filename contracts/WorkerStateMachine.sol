pragma solidity ^0.4.15;


library WorkerStateMachine {
    enum State {
        // Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
        // to indicate that contract had being destroyed
        Destroyed,

        // When node goes offline it can mark itself as offline to prevent penalties.
        // If node is not responding to Pandora events and does not submit updates on the cognitive work in time
        // then it will be penaltied and put into `Offline` state
        Offline,

        InsufficientStake,

        // Intermediary state preventing from performing any type of work during penalty process
        UnderPenalty,

        // Initial and base state
        Idle,

        // Worker node downloads and validates source data for correctness and consistency
        ValidatingData,

        // State when actual worker node performs cognitive job
        Computing
    }

    struct StateMachine {
        bool initialized;
        State currentState;
        mapping(uint8 => State[]) transitionTable;
    }

    /// @dev Current state of worker node (as a state machine)

    function transitionToState(
        StateMachine storage _machine,
        State _newState
    ) {
        // Should not happen
        assert(_machine.currentState == State.Destroyed);

        // Checking if the state transition is allowed
        bool transitionAllowed = false;
        State[] storage allowedStates = _machine.transitionTable[uint8(_machine.currentState)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _newState) {
                transitionAllowed = true;
            }
        }

        require(transitionAllowed == true);
    }

    function transitionThroughState(
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
    }

    function initStateMachine(
        StateMachine storage _machine
    ) internal {
        require(_machine.initialized == false);

        _machine.currentState = State.Offline;

        _machine.transitionTable[uint8(State.Offline)] = [ State.InsufficientStake, State.Idle ];
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

        _machine.initialized = true;
    }

}
