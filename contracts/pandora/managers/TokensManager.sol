pragma solidity 0.4.24;

import "../token/PAN.sol";
import "../../libraries/LedgersLib.sol";
import "./ITokensManager.sol";


/**
 * @title TokensManager
 * @dev This contract represents tokens management logic
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
contract TokensManager is ITokensManager, Pan {

    using LedgersLib for LedgersLib.LedgersStorage;    

    /**
     * @dev Internal ledgers storage    
     */
    LedgersLib.LedgersStorage internal ledgers;

    function blockTokens(uint256 value) public {
        require(balanceOf(msg.sender) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _transfer(msg.sender, address(this), value);

        if (!ledgers.isLedgerExists(msg.sender)) {
            ledgers.put(msg.sender);
        }
        
        ledgers.add(msg.sender, value);
        emit BlockedTokens(msg.sender, value);
    }

    function blockTokensFrom(
        address from,
        uint256 value
    ) internal {
        require(balanceOf(from) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _transfer(from, address(this), value);

        if (!ledgers.isLedgerExists(from)) {
            ledgers.put(from);
        }
        
        ledgers.add(from, value);
        emit BlockedTokens(from, value);
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
