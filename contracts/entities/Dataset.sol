pragma solidity ^0.4.23;

import "./DataEntity.sol";
import "./IDataset.sol";

/*
 */

contract Dataset is DataEntity, IDataset {
    uint8 public batchesCount;
    bytes32 public metadata;
    bytes32 public description;

    /// @dev Constructor receives an address of the main IPFS dataset information file (in JSON format) and four
    /// core arguments (also present in that file) which are required for smartcontracts to be able to initialize
    /// cognitive jobs and check compliance with the selected kernel
    constructor(
        bytes _ipfsAddress,     /// Address for the JSON file stored in IPFS that keeps all necessary information on
                                /// the dataset, including IPFS addresses for each batch in HD5F format
        uint256 _dataDim,       /// Dimension of the single dataset sample (that goes to the input layer of the
                                /// kernel neural network
        uint8 _batchesCount,    /// Amount of batches defined in the information JSON file (each batch will be computed
                                /// by a separate worker node
        uint256 _initialPrice,  /// Price for which Dataset owner is ready to rent the kernel
        bytes32 _metadata,    /// Data, tags that helps to recognize dataset
        bytes32 _description    /// Dataset description
    )
    DataEntity(_ipfsAddress, _dataDim, _initialPrice)
    public {
        batchesCount = _batchesCount;
        metadata = _metadata;
        description = _description;
    }
}
