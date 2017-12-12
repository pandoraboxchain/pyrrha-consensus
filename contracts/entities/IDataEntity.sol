pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract IDataEntity is Ownable {
    bytes public ipfsAddress;
    uint256 public dataDim;
    uint256 public currentPrice;

    function updatePrice(uint256 newPrice) external;
    function withdrawBalance() external;

    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
}

contract IDataset is IDataEntity {
    uint256 public samplesCount;
    uint8 public batchesCount;
}

contract IKernel is IDataEntity {
    uint256 public complexity;
}
