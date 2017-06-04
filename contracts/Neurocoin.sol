pragma solidity ^0.4.8;

import './zeppelin/token/MintableToken.sol';

contract Neurocoin is MintableToken {
    string public name = "Neurochain Network Token";
    string public symbol = "NNT";
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 10000;

    function Neurocoin() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
