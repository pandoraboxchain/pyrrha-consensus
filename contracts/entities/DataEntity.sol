pragma solidity ^0.4.23;

import "./IDataEntity.sol";

/**
 * @title DataEntity Contract (parent for Kernel and Dataset contracts)
 * @author "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>
 *
 * @dev Root contract for data entities and their workflows. For more details please refer to the
 * [Technical specification](https://github.com/pandoraboxchain/techspecs/wiki/Creating-data-entities)
 */

contract DataEntity is IDataEntity {

    /// @dev Address of IPFS metadata file in JSON format that contains all necessary information about data entity,
    /// together with references on other data files stored in IPFS (models, big data sets and data chunks etc)
    bytes public ipfsAddress;

    /// @dev Data dimension: sample data vector length for datasets and input layer vector length for AI kernel.
    /// Needs to be present in blockchain storage since used by the Pandora contract for checking during creation of
    /// cognitive job contract (dataset and kernel dimensions must match).
    uint256 public dataDim;

    /// @dev Current price (in PAN tokens) for the single use of the data entity
    uint256 public currentPrice;

    /// @dev Fired by `updatePrice` function
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);

    constructor(
        bytes _ipfsAddress,
        uint256 _dataDim,
        uint256 _initialPrice
    )
    public
    payable {
        dataDim = _dataDim;
        ipfsAddress = _ipfsAddress;
        currentPrice = _initialPrice;
    }

    function updatePrice (
        uint256 _newPrice
    ) external
        onlyOwner
    {
        uint256 oldPrice = currentPrice;
        currentPrice = _newPrice;

        emit PriceUpdated(oldPrice, _newPrice);
    }

    /// @notice Withdraws full balance to the owner account. Can be called only by the owner of the contract.
    function withdrawBalance(
        // No arguments
    ) external
        onlyOwner // Can be called only by the owner
    {
        owner.transfer(address(this).balance);
    }
}
