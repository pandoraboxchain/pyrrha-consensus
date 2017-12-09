pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Pandora.sol";
import "../contracts/lottery/RoundRobinLottery.sol";

contract TestRoundRobinLottery {
    RoundRobinLottery engine;

    function TestRoundRobinLottery(){
        engine = RoundRobinLottery(Pandora(DeployedAddresses.Pandora()).workerLotteryEngine());
    }

    function testRandom() {
        Assert.equal(engine.getRandom(7), 0, "First lottery result must be zero");
    }
}
