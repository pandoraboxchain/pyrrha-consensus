pragma solidity ^0.4.18;

import './DataEntity.sol';

/*
  Kernel Contract represents information about specific fixed machine learning kernel
  (trained model saved on IPFS and identified by its file id)

  Kernels are transferrable
  Kernel model data are updatable (but update simple creates new kernel)
  Price can be edited
 */

contract Kernel is DataEntity, IKernel {
    uint256 public complexity;

    function Kernel (
        bytes _ipfsAddress,
        uint256 _dataDim,
        uint256 _complexity,
        uint256 _initialPrice
    )
    DataEntity(_ipfsAddress, _dataDim, _initialPrice)
    public {
        complexity = _complexity;
    }
}
