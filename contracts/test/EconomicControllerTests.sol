pragma solidity ^0.4.24;

import "../pandora/managers/ICognitiveJobManager.sol";
import "../pandora/managers/IEconomicController.sol";

/**
 * @title EconomicControllerTests
 * @dev This contract represents tokens management logic
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
contract EconomicControllerTests {

    address public economicController;

    constructor (address _economicController) public {
        economicController = _economicController;
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
        IEconomicController(economicController).unblockTokens(from, to, value);
    }
}
