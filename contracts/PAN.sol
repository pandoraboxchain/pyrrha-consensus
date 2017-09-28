pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract PAN is StandardToken {
    string public name = "Pandora";
    string public symbol = "PAN";
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 5000000;

    function PAN() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
