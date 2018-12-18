pragma solidity 0.4.24;


/**
 * @title ITokensManager
 * @dev TokensManager interface
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
contract ITokensManager {

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
        address from,
        address to,
        uint256 value
    );

    function blockTokens(uint256 value) public {}

    function blockTokensFrom(
        address from,
        uint256 value
    ) internal {}

    function blockWorkerNodeStake(uint256 tokensToStake) public {}

    function unblockTokensFrom(
        address from, 
        address to,
        uint256 value
    ) internal {}

    function hasAvailableFunds(address addr) public view returns (bool) {}

    function hasWorkerNodeStake(address addr) public view returns (bool) {}

    function getAvailableBalance(address addr) public view returns (uint256) {}
}
