pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract IDataEntity is Ownable {
    bytes public ipfsAddress;
    uint256 public dataDim;
    uint256 public currentPrice;

    function updatePrice(uint256 newPrice) external;
    function withdrawBalance() external;

    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
}
