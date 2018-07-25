pragma solidity ^0.4.23;

import "./ILotteryEngine.sol";

contract RandomEngine is ILotteryEngine {
    bytes32 baseHash;
    uint256 lastBlockNumber;

    constructor()
    public {
        lastBlockNumber = block.number;
    }

    // Current implementation able to return one unique value per block
    function getRandom(uint256 _max)
    public
    returns (uint256 o_result) {
        if (block.number > lastBlockNumber) {
            lastBlockNumber = block.number;
            baseHash = keccak256(abi.encodePacked(uint256(blockhash(block.number)) + uint256(blockhash(block.number - 10))));
        } else {
            baseHash = keccak256(abi.encodePacked(baseHash));
        }
        o_result = uint256(baseHash) % _max;
    }
}
