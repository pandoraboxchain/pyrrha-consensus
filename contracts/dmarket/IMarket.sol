pragma solidity ^0.4.23;

import "../entities/IKernel.sol";
import "../entities/IDataset.sol";

contract IMarket {
    IKernel[] public kernels;
    IDataset[] public datasets;
    mapping(address => uint32) public kernelMap;
    mapping(address => uint32) public datasetMap;

    event KernelAdded(IKernel kernel);
    event DatasetAdded(IDataset dataset);
    event KernelRemoved(IKernel kernel);
    event DatasetRemoved(IDataset dataset);

    function kernelsCount() external view returns (uint);
    function datasetsCount() external view returns (uint);

    function addKernel(IKernel _kernel) external returns (uint8);
    function addDataset(IDataset _dataset) external returns (uint8);
    function removeKernel(IKernel _kernel) external returns (uint8);
    function removeDataset(IDataset _dataset) external returns (uint8);
}
