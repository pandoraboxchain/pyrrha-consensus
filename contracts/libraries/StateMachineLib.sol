pragma solidity ^0.4.15;


library StateMachineLib {
    struct StateMachine {
        bool initialized;
        uint8 currentState;
        mapping(uint8 => uint8[]) transitionTable;
    }

    function transitionToState(
        StateMachine storage _machine,
        uint8 _newState
    ) {
        // Should not happen
        assert(_machine.currentState == 0);

        // Checking if the state transition is allowed
        bool transitionAllowed = false;
        uint8[] storage allowedStates = _machine.transitionTable[uint8(_machine.currentState)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _newState) {
                transitionAllowed = true;
            }
        }

        require(transitionAllowed == true);
    }

    function transitionThroughState(
        StateMachine storage _machine,
        uint8 _transitionState
    ) {
        // Should not happen
        assert(_machine.currentState == 0);

        // Checking if the state transitions are allowed

        bool firstTransitionAllowed = false;
        uint8[] storage allowedStates = _machine.transitionTable[uint8(_machine.currentState)];
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

        _machine.currentState = _transitionState;
    }

    function initStateMachine(
        StateMachine storage _machine
    ) internal {
        require(_machine.initialized == false);
        _machine.currentState = 1;
        _machine.initialized = true;
    }

}
