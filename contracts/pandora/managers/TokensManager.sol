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
     * @dev This event will be emitted every time the stake is added
     * @param owner Stake owner address
     * @param value Stake value
     */
    event StakeAdded(
        address indexed owner, 
        uint256 indexed value
    );

    /**
     * @dev This event will be emitted every time the stake is blocked
     * @param owner Stake owner address
     * @param value Stake value
     */
    event StakeBlocked(
        address indexed owner, 
        uint256 indexed value
    );

    constructor () public {
        ledgers.put(address(this));
    }

    function addWorkerNodeStake(uint256 tokensToStake) public {
        require(tokensToStake >= minimumWorkerNodeStake, "ERROR_INSUFFICIENT_WORKER_NODE_STAKE");
        require(balanceOf(msg.sender) >= tokensToStake, "ERROR_INSUFFICIENT_TOKENS");
        transfer(address(this), tokensToStake);

        if (!ledgers.isLedgerExists(msg.sender)) {
            ledgers.put(msg.sender);
        }
        
        ledgers.deposit(msg.sender, tokensToStake);
        emit StakeAdded(msg.sender, tokensToStake);

        ledgers.blockFunds(msg.sender, minimumWorkerNodeStake);
        emit StakeBlocked(msg.sender, minimumWorkerNodeStake);
    }

    function isWorkerNodeHasStake(address addr) public view returns (bool) {
        return ledgers.totalBalanceOf(addr) >= minimumWorkerNodeStake;
    }
}
