pragma solidity ^0.4.23;

import "./DataEntity.sol";
import "./IKernel.sol";

/*
  Kernel Contract represents information about specific fixed machine learning kernel
  (trained model saved on IPFS and identified by its file id)

  Kernels are transferrable
  Kernel model data are updatable (but update simple creates new kernel)
  Price can be edited
 */

contract Kernel is DataEntity, IKernel {
    uint256 public complexity;
    bytes32 public metadata;
    bytes32 public description;

    /// @dev Constructor receives an address of the main IPFS kernel info file and three core arguments (also present
    /// in that file) which are required for smartcontracts to be able to initialize cognitive jobs and check
    /// compliance with the selected dataset
    constructor(
        bytes _ipfsAddress,     /// Address for the JSON file stored in IPFS that keeps all necessary information on
                                /// the kernel, including IPFS addresses for HD5F files with weights and JSON model
        uint256 _dataDim,       /// Dimension of the input vector for the topmost network layer
        uint256 _complexity,    /// Amount of computing operations that must be performed for a single data pass
                                /// throughout neural network to get a single result
        uint256 _initialPrice,  /// Price for which Kernel author is ready to rent the kernel
        bytes32 _metadata,    /// Data, tags that helps to recognize kernel
        bytes32 _description    /// Kernel description
    )
    DataEntity(_ipfsAddress, _dataDim, _initialPrice)
    public {
        complexity = _complexity;
        metadata = _metadata;
        description = _description;
    }
}
