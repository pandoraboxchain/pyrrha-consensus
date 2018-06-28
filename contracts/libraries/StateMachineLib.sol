pragma solidity ^0.4.23;


library StateMachineLib {

    struct StateMachine {
        bool initialized;
        uint8 currentState;
        mapping(uint8 => uint8[]) transitionTable;
    }

    function isTransitionAllowed(
        StateMachine storage _machine,
        uint8 _newState
    )
    view
    internal {
        // Should not happen
        assert(_machine.currentState != 0xFF);

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

//    function isTransitionThroughStateAllowed(
//        StateMachine storage _machine,
//        uint8 _transitionState
//    )
//    internal {
//        // Should not happen
//        assert(_machine.currentState != 0xFF);
//
//        // Checking if the state transitions are allowed
//
//        bool firstTransitionAllowed = false;
//        uint8[] storage allowedStates = _machine.transitionTable[uint8(_machine.currentState)];
//        for (uint no = 0; no < allowedStates.length; no++) {
//            if (allowedStates[no] == _transitionState) {
//                firstTransitionAllowed = true;
//                break;
//            }
//        }
//        require(firstTransitionAllowed == true);
//
//        bool secondTransitionAllowed = false;
//        allowedStates = _machine.transitionTable[uint8(_transitionState)];
//        for (no = 0; no < allowedStates.length; no++) {
//            if (allowedStates[no] == _machine.currentState) {
//                secondTransitionAllowed = true;
//                break;
//            }
//        }
//        require(secondTransitionAllowed == true);
//    }

    function requireStates2(
        StateMachine storage _machine,
        uint8 _requiredState1,
        uint8 _requiredState2
    )
    view
    internal {
        bool properState = false;
        if (_requiredState1 == _machine.currentState) {
            properState = true;
        }
        if (_requiredState2 == _machine.currentState) {
            properState = true;
        }
        require(properState == true);
    }

    function initStateMachine(
        StateMachine storage _machine
    ) internal {
        require(_machine.initialized == false);
        _machine.currentState = 1;
        _machine.initialized = true;
    }
}
