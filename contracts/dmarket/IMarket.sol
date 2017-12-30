pragma solidity ^0.4.18;

import "../entities/IKernel.sol";
import "../entities/IDataset.sol";

contract IMarket {
    IKernel[] public kernels;
    IDataset[] public datasets;
    mapping(address => bool) public kernelMap;
    mapping(address => bool) public datasetMap;

    event KernelAdded(IKernel kernel);
    event DatasetAdded(IDataset dataset);

    function addKernel(IKernel _kernel) external returns (bool);
    function addDataset(IDataset _dataset) external returns (bool);
}
