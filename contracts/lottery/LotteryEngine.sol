pragma solidity ^0.4.15;


contract /* interface */ LotteryEngine {
    function getRandom(uint256 _max) public constant returns (uint256 o_result);
}
