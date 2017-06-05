pragma solidity ^0.4.8;

/*
 */

import './IntellectualPropertyContract.sol';

contract DatasetContract is IntellectualPropertyContract {
    uint public sampleCount;

    function DatasetContract (
        bytes _ipfsAddress, uint _currentPrice, uint _sampleCount
    ) IntellectualPropertyContract(_ipfsAddress, _currentPrice) {
        sampleCount = _sampleCount;
    }
}
