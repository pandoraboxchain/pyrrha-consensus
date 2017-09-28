pragma solidity ^0.4.15;

/*
 */

import './DataEntity.sol';

contract Dataset is DataEntity {
    uint256 public samplesCount;

    function Dataset (
        bytes _ipfsAddress,
        uint256 _dataDim,
        uint256 _samplesCount,
        uint256 _initialPrice
    ) DataEntity(_ipfsAddress, _dataDim, _initialPrice) {
        samplesCount = _samplesCount;
    }
}
