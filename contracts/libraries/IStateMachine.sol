pragma solidity ^0.4.23;


contract IStateMachine {

    function currentState() public view returns (uint8);

    event StateChanged(uint8 oldState, uint8 newState);
}