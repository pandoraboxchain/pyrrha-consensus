pragma solidity ^0.4.15;

import './zeppelin/ownership/Ownable.sol';
import './Pandora.sol';

/*

 */

contract WorkerNode is Ownable {
    enum State {
        Idle, Computing
    }

    State public currentState;
    Pandora private pandora;

    function WorkerNode (Pandora _pandora) {
        pandora = _pandora;
        currentState = State.Idle;
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
    }

    function updateState(State _newState) external onlyPandora {
        currentState = _newState;
    }
}
