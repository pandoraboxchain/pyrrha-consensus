pragma solidity ^0.4.18;

import "../entities/IKernel.sol";
import "../entities/IDataset.sol";
import "./IMarket.sol";

contract PandoraMarket is IMarket {
    IKernel[] public kernels;
    IDataset[] public datasets;
    mapping(address => uint32) public kernelMap;
    mapping(address => uint32) public datasetMap;

    /// @dev Since functions of destroyed contracts return zero then we have to reserve zero value as a special
    /// indicator of the failed contract
    uint8 public constant STATUS_FAILED_CONTRACT = 0;
    uint8 public constant STATUS_SUCCESS = 1;
    uint8 public constant STATUS_NO_SPACE = 2;
    uint8 public constant STATUS_ALREADY_EXISTS = 3;
    uint8 public constant STATUS_NOT_EXISTS = 4;

    event KernelAdded(IKernel kernel);
    event KernelAddFailed(uint8 reason);
    event DatasetAdded(IDataset dataset);
    event DatasetAddFailed(uint8 reason);
    event KernelRemoved(IKernel kernel);
    event KernelRemoveFailed(uint8 reason);
    event DatasetRemoved(IDataset dataset);
    event DatasetRemoveFailed(uint8 reason);

    function PandoraMarket() {
    }

    function kernelsCount()
    external
    view
    returns (
        uint32 o_count
    ) {
        o_count = kernels.length;
    }

    function datasetsCount()
    external
    view
    returns (
        uint32 o_count
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
            o_result = STATUS_NO_SPACE;
            KernelAddFailed(o_result);
            return o_result;
        }
        if (kernelMap[address(_kernel)] != 0) {
            o_result = STATUS_ALREADY_EXISTS;
            KernelAddFailed(o_result);
            return o_result;
        }
        kernels.push(_kernel);
        kernelMap[address(_kernel)] = kernels.length;
        KernelAdded(_kernel);
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
            o_result = STATUS_NO_SPACE;
            DatasetAddFailed(o_result);
            return o_result;
        }
        if (datasetMap[address(_dataset)] != 0) {
            o_result = STATUS_ALREADY_EXISTS;
            DatasetAddFailed(o_result);
            return o_result;
        }
        datasets.push(_dataset);
        datasetMap[address(_dataset)] = datasets.length;
        DatasetAdded(_dataset);
        return o_result = STATUS_SUCCESS;
    }

    function removeKernel(
        IKernel _kernel
    )
    external
    returns (
        uin8 o_result
    ) {
        uint32 pos = kernelMap[address(_kernel)];
        if (pos == 0) {
            o_result = STATUS_NOT_EXISTS;
            KernelRemoveFailed(o_result);
            return o_result;
        }

        uint len = kernels.length;
        IKernel lastKernel = kernels[len - 1];
        kernels[pos] = lastKernel;
        kernelMap[address(_kernel)] = 0;
        kernelMap[address(lastKernel)] = pos;
        delete kernels[len - 1];

        KernelRemoved(_kernel);

        return o_result = STATUS_SUCCESS;
    }

    function removeDataset(
        IDataset _dataset
    )
    external
    returns (
        uin8 o_result
    ) {
        uint32 pos = datasetMap[address(_dataset)];
        if (pos == 0) {
            o_result = STATUS_NOT_EXISTS;
            DatasetRemoveFailed(o_result);
            return o_result;
        }

        uint len = datasets.length;
        IDataset lastDataset = datasets[len - 1];
        datasets[pos] = lastDataset;
        datasetMap[address(_dataset)] = 0;
        datasetMap[address(lastDataset)] = pos;
        delete datasets[len - 1];

        DatasetRemoved(_dataset);

        return o_result = STATUS_SUCCESS;
    }
}
