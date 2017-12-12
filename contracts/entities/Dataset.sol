pragma solidity ^0.4.18;

/*
 */

import './DataEntity.sol';

contract Dataset is DataEntity, IDataset {
    uint256 public samplesCount;
    uint8 public batchesCount;

    function Dataset (
        bytes _ipfsAddress,
        uint256 _dataDim,
        uint256 _samplesCount,
        uint8 _batchesCount,
        uint256 _initialPrice
    )
    DataEntity(_ipfsAddress, _dataDim, _initialPrice)
    public {
        samplesCount = _samplesCount;
        batchesCount = _batchesCount;
    }
}
