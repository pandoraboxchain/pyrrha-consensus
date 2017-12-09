pragma solidity ^0.4.0;

import './LotteryEngine.sol';

contract RoundRobinLottery is LotteryEngine {

    uint256 internal m_lastValue;

    function RoundRobinLottery() {
        m_lastValue = 0;
    }

    function getRandom(uint256 _max) public constant returns (uint256 o_result) {
        if (m_lastValue >= _max) {
            m_lastValue = 0;
        }
        o_result = m_lastValue;
        m_lastValue++;
    }
}
