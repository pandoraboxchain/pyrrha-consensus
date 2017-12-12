pragma solidity ^0.4.18;

contract JobStates {
    // Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
    // to indicate that contract had being destroyed
    uint8 public constant Destroyed = 0xFF;

    // Reserved system state not participating in transition table. Since contract creation all variables are
    // initialized to zero and contract state will be zero until it will be initialized with some definite state
    uint8 public constant Uninitialized = 0;

    uint8 public constant GatheringWorkers = 1;

    uint8 public constant InsufficientWorkers = 2;

    uint8 public constant DataValidation = 3;

    uint8 public constant InvalidData = 4;

    uint8 public constant Cognition = 5;

    uint8 public constant PartialResult = 6;

    uint8 public constant Completed = 7;
}
