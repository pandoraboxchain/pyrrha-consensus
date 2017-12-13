pragma solidity ^0.4.18;

import './ILotteryEngine.sol';

contract RoundRobinLottery is ILotteryEngine {

    uint256 internal m_lastValue;

    function RoundRobinLottery()
    public {
        m_lastValue = 0;
    }

    function getRandom(uint256 _max)
    public
    returns (uint256 o_result) {
        if (m_lastValue >= _max) {
            m_lastValue = 0;
        }
        o_result = m_lastValue;
        m_lastValue++;
    }
}
