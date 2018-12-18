pragma solidity 0.4.24;

import "../pandora/managers/TokensManager.sol";

/**
 * @title TokensManager
 * @dev This contract represents tokens management logic
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
contract TokensManagerTests is TokensManager {

    /**
     * @dev Unblock tokens and send to address
     * @param from Source address
     * @param to Destination address
     * @param value Value
     */
    function testUnblockTokensFrom(
        address from, 
        address to,
        uint256 value
    ) public {
        unblockTokensFrom(from, to, value);
    }
}
