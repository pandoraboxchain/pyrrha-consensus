pragma solidity 0.4.24;

import "../token/PAN.sol";
import "../../libraries/LedgersLib.sol";


/**
 * @title TokensManager
 * @dev This contract represents tokens management logic
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
contract TokensManager is Pan {

    using LedgersLib for LedgersLib.LedgersStorage;

    uint256 public constant minimumWorkerNodeStake = 100 * 1000000000000000000;// 100 PAN

    /**
     * @dev Internal ledgers storage    
     */
    LedgersLib.LedgersStorage internal ledgers;

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

    function blockTokens(uint256 value) public {
        require(balanceOf(msg.sender) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _transfer(msg.sender, address(this), value);

        if (!ledgers.isLedgerExists(msg.sender)) {
            ledgers.put(msg.sender);
        }
        
        ledgers.add(msg.sender, value);
        emit BlockedTokens(msg.sender, value);
    }

    function blockWorkerNodeStake(uint256 tokensToStake) public {
        require(tokensToStake >= minimumWorkerNodeStake, "ERROR_INSUFFICIENT_WORKER_NODE_STAKE");
        blockTokens(tokensToStake);
    }

    function unblockTokensFrom(
        address from, 
        address to,
        uint256 value
    ) internal {
        require(to != address(0), "ERROR_INVALID_ADDRESS");
        ledgers.sub(from, value);
        _transfer(address(this), to, value);
        emit UnblockedTokens(from, to, value);
    }

    function hasAvailableFunds(address addr) public view returns (bool) {
        return ledgers.balanceOf(addr) > 0;
    }

    function hasWorkerNodeStake(address addr) public view returns (bool) {
        return ledgers.balanceOf(addr) >= minimumWorkerNodeStake;
    }

    function getAvailableBalance(address addr) public view returns (uint256) {
        return ledgers.balanceOf(addr);
    }
}
