pragma solidity ^0.4.23;

import "./ILotteryEngine.sol";

contract RandomEngine is ILotteryEngine {

    constructor()
    public {
    }

    function getRandom(uint256 _max)
    public
    returns (uint256 o_result) {
        o_result = (uint(blockhash(block.number)) + uint(blockhash(block.number - 10))) % _max;
    }
}
