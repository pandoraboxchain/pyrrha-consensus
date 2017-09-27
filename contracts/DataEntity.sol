pragma solidity ^0.4.15;

/*

 */

import './zeppelin/lifecycle/Destructible.sol';

contract DataEntity is Destructible {
    uint256 public currentPrice;
    bytes public ipfsAddress;
    uint256 public dimension;

    function DataEntity (uint256 _currentPrice, bytes _ipfsAddress, uint256 _dimension) {
        currentPrice = _currentPrice;
        dimension = _dimension;
        ipfsAddress = _ipfsAddress;
    }

    function updatePrice (uint newPrice) external onlyOwner {
        currentPrice = newPrice;
    }
}
