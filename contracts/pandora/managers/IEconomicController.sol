pragma solidity 0.4.24;

import "../../nodes/IWorkerNode.sol";


contract IEconomicController {

    uint256 public constant minimumWorkerNodeStake = 100 * 1000000000000000000;// 100 PAN

    /**
     * @dev This event will be emitted every time tokens are blocked
     * @param owner Tokens owner address
     * @param value Tokens value
     */
    event BlockedTokens(
        address indexed owner, 
        uint256 indexed value
    );

    /**
     * @dev This event will be emitted every time tokens are unblocked and transfered to address
     * @param from Blocked funds owner address
     * @param to Destination address
     * @param value Tokens value
     */
    event UnblockedTokens(
        address indexed from,
        address indexed to,
        uint256 value
    );

    /**
     * @dev This event will be emitted every time a penalty been applied to the stake owner
     * @param owner Stake owner address
     * @param value Penalty value
     */
    event PenaltyApplied(
        IWorkerNode.Penalties reason,
        address indexed owner,
        uint256 value
    );

    function blockWorkerNodeStake() external {}// block tokens from sender with worker node stake amount control
    function hasAvailableFunds(address addr) external view returns (bool) {}
    function hasEnoughFunds(address addr, uint256 funds) external view returns (bool) {}
    function positiveWorkerNodeStake(address workerNodeAddr) external view returns (bool) {}
    function unblockTokens(address from, address to, uint256 value) external {}
    function applyPenalty(IWorkerNode.Penalties reason, address owner) external {}
    function balanceOf(address addr) external view returns (uint256) {}

    function blockTokens(uint256 value) public {}// block tokens from sender

    function _add(address addr, uint256 value) private {}
    function _sub(address from, uint256 value) private {}
    function _block(address from, uint256 value) private {}
}
