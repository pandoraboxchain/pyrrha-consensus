pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/pandora/lottery/RoundRobinLottery.sol";

contract TestRoundRobinLottery {
    RoundRobinLottery engine;
    uint8 rounds;

    function beforeAll(){
        engine = new RoundRobinLottery();
    }

    function testFirstRound() {
        rounds = 6;
        uint8 no = 0;
        for (no = 0; no < rounds; no++)
            Assert.equal(engine.getRandom(rounds), no, "First lottery result must increment");
    }

    function testRoundSwitch() {
        Assert.equal(engine.getRandom(rounds), 0, "Lottery must reset upon reaching the last value");
    }

    function testNextRound() {
        for (uint8 no = 1; no < rounds; no++)
            Assert.equal(engine.getRandom(rounds), no, "First lottery result must increment");
    }

    function testUpRound() {
        uint8 moreRounds = rounds + 6;
        for (uint8 no = rounds; no < moreRounds - 2; no++)
            Assert.equal(engine.getRandom(moreRounds), no, "Random must proceed with increments if we put more rounds");
        rounds = moreRounds;
    }

    function testDownRound() {
        Assert.equal(engine.getRandom(rounds - 10), 0, "Random must reset to zero if we reduce max number when current value is more then max");
    }
}
