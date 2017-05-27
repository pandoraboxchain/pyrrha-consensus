pragma solidity ^0.4.0;

/*
 */

import 'IntellectualPropertyContract.sol';

contract DatasetContract is IntellectualPropertyContract {
    uint sampleCount;

    function DatasetContract (
        bytes _ipfsAddress, uint _currentPrice, uint _sampleCount
    ) IntellectualPropertyContract(_ipfsAddress, _currentPrice) {
        sampleCount = _sampleCount;
    }
}
