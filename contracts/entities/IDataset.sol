pragma solidity ^0.4.18;

import './IDataEntity.sol';

contract IDataset is IDataEntity {
    uint256 public samplesCount;
    uint8 public batchesCount;
}
