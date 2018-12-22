pragma solidity 0.4.24;


contract IEconomicController {

    function add(address addr, uint256 value) external {}

    function sub(address from, uint256 value) external {}

    function balanceOf(address addr) external view returns (uint256) {}

    function addFrom(address from, uint256 value) external {}

    function positiveWorkerNodeStake(address workerNodeAddr) external view returns (bool) {}

}
