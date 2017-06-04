pragma solidity ^0.4.8;

/*

 */

import './zeppelin/lifecycle/Destructible.sol';

contract IntellectualPropertyContract is Destructible {
    bytes public ipfsAddress;
    uint public currentPrice;

    function IntellectualPropertyContract (bytes _ipfsAddress, uint _currentPrice) {
        ipfsAddress = _ipfsAddress;
        currentPrice = _currentPrice;
    }

    function updatePrice (uint newPrice) onlyOwner external returns (uint oldPrice) {
        oldPrice = currentPrice;
        currentPrice = newPrice;
    }

    /*
    function updateVersion (bytes newIPFSAddress) onlyOwner external returns (IntellectualPropertyContract newContract) {
        newContract = new IntellectualPropertyContract(newIPFSAddress, currentPrice);
    }

    function updateVersionAndPrice (bytes newIPFSAddress, uint newPrice) onlyOwner external returns (IntellectualPropertyContract newContract) {
        newContract = new IntellectualPropertyContract(newIPFSAddress, newPrice);
    }
    */
}
