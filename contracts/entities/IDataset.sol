pragma solidity 0.4.23;

import "./IDataEntity.sol";

contract IDataset is IDataEntity {
    uint256 public samplesCount;
    uint8 public batchesCount;
}
