pragma solidity ^0.4.18;

import "../entities/IKernel.sol";
import "../entities/IDataset.sol";
import "./IMarket.sol";

contract PandoraMarket is IMarket {
    IKernel[] public kernels;
    IDataset[] public datasets;
    mapping(address => bool) public kernelMap;
    mapping(address => bool) public datasetMap;

    event KernelAdded(IKernel kernel);
    event DatasetAdded(IDataset dataset);

    function PandoraMarket() {
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

    function addKernel(IKernel _kernel)
    external
    returns (bool) {
        if (kernelMap[address(_kernel)] == true) {
            return false;
        }
        kernelMap[address(_kernel)] = false;
        kernels.push(_kernel);
        KernelAdded(_kernel);
        return true;
    }

    function addDataset(IDataset _dataset)
    external
    returns (bool) {
        if (datasetMap[address(_dataset)] == true) {
            return false;
        }
        datasetMap[address(_dataset)] = false;
        datasets.push(_dataset);
        DatasetAdded(_dataset);
        return true;
    }
}
