pragma solidity ^0.4.23;

import "../entities/IKernel.sol";
import "../entities/IDataset.sol";
import "./IMarket.sol";

contract PandoraMarket is IMarket {
    IKernel[] public kernels;
    IDataset[] public datasets;
    mapping(address => uint256) public kernelMap;
    mapping(address => uint256) public datasetMap;

    /// @dev Since functions of destroyed contracts return zero then we have to reserve zero value as a special
    /// indicator of the failed contract
    uint8 public constant STATUS_FAILED_CONTRACT = 0;
    uint8 public constant STATUS_SUCCESS = 1;
    uint8 public constant STATUS_NO_SPACE = 2;
    uint8 public constant STATUS_ALREADY_EXISTS = 3;
    uint8 public constant STATUS_NOT_EXISTS = 4;

    event KernelAdded(IKernel kernel);
    event DatasetAdded(IDataset dataset);
    event KernelRemoved(IKernel kernel);
    event DatasetRemoved(IDataset dataset);

    constructor() public {
    }

    function kernelsCount()
    external
    view
    returns (
        uint o_count
    ) {
        o_count = kernels.length;
    }

    function datasetsCount()
    external
    view
    returns (
        uint o_count
    ) {
        o_count = datasets.length;
    }

    function addKernel(
        IKernel _kernel
    )
    external
    returns (
        uint8 o_result
    ) {
        if (kernels.length >= 0xFFFFFFFE) {
            return o_result = STATUS_NO_SPACE;
        }
        if (kernelMap[address(_kernel)] != 0) {
            return o_result = STATUS_ALREADY_EXISTS;
        }
        kernels.push(_kernel);
        kernelMap[address(_kernel)] = kernels.length;
        emit KernelAdded(_kernel);
        return o_result = STATUS_SUCCESS;
    }

    function addDataset(
        IDataset _dataset
    )
    external
    returns (
        uint8 o_result
    ) {
        if (datasets.length >= 0xFFFFFFFE) {
            return o_result = STATUS_NO_SPACE;
        }
        if (datasetMap[address(_dataset)] != 0) {
            return o_result = STATUS_ALREADY_EXISTS;
        }
        datasets.push(_dataset);
        datasetMap[address(_dataset)] = datasets.length;
        emit DatasetAdded(_dataset);
        return o_result = STATUS_SUCCESS;
    }

    function removeKernel(
        IKernel _kernel
    )
    external
    returns (
        uint8 o_result
    ) {
        uint256 pos = kernelMap[address(_kernel)];
        if (pos == 0) {
            return o_result = STATUS_NOT_EXISTS;
        }

        uint len = kernels.length;
        IKernel lastKernel = kernels[len - 1];
        kernels[pos - 1] = lastKernel;
        kernelMap[address(_kernel)] = 0;
        kernelMap[address(lastKernel)] = pos;
        delete kernels[len - 1];
        kernels.length--;

        emit KernelRemoved(_kernel);

        return o_result = STATUS_SUCCESS;
    }

    function removeDataset(
        IDataset _dataset
    )
    external
    returns (
        uint8 o_result
    ) {
        uint256 pos = datasetMap[address(_dataset)];
        if (pos == 0) {
            return o_result = STATUS_NOT_EXISTS;
        }

        uint len = datasets.length;
        IDataset lastDataset = datasets[len - 1];
        datasets[pos - 1] = lastDataset;
        datasetMap[address(_dataset)] = 0;
        datasetMap[address(lastDataset)] = pos;
        delete datasets[len - 1];
        datasets.length--;

        emit DatasetRemoved(_dataset);

        return o_result = STATUS_SUCCESS;
    }
}
