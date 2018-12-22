pragma solidity 0.4.24;

import "../pandora/token/PAN.sol";
import "../pandora/managers/IEconomicController.sol";

/**
 * @title EconomicManagerTests
 * @dev This contract represents tokens management logic
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
contract EconomicManagerTests is Pan {

    constructor(IEconomicController _economicController)
    Pan(_economicController) {}

    /**
     * @dev Block tokens 
     * @param from Source address
     * @param value Value
     */
    function testBlockTokensFrom(
        address from,
        uint256 value
    ) public {
        blockTokensFrom(from, value);
    }

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
