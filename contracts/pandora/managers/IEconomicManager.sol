pragma solidity 0.4.24;

import "../../nodes/IWorkerNode.sol";


/**
 * @title IEconomicManager
 * @dev Pan token interface for economic related functions
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
contract IEconomicManager {

    uint256 public constant minimumWorkerNodeStake = 100 * 1000000000000000000;// 100 PAN

    function blockTokens(uint256 value) public {}

    function blockWorkerNodeStake(uint256 tokensToStake) public {}

    function hasAvailableFunds(address addr) public view returns (bool) {}

    function hasEnoughFunds(address addr, uint256 funds) public view returns (bool) {}

    function hasWorkerNodeAvailableFunds(address workerNodeAddr) public view returns (bool) {}

    function getAvailableBalance(address addr) public view returns (uint256) {}

    function blockTokensFrom(
        address from,
        uint256 value
    ) internal {}

    function unblockTokensFrom(
        address from, 
        address to,
        uint256 value
    ) internal {}

    function applyPenalty(
        IWorkerNode.Penalties reason, 
        address owner
    ) internal {}
}
