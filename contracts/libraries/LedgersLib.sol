pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title LedgersLib
 * @dev This library hold a tokens management logic
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
library LedgersLib {

    using SafeMath for uint256;

    uint256 private constant minimumTokensAmount = 1;

    struct Ledger {
        address addr;
        uint256 balance;
        uint256 blockedFunds;
    }

    struct LedgersStorage {
        uint256 count;
        mapping (address => Ledger) ledgers;
        mapping (address => uint256) ids;
        mapping (uint256 => address) addresses;
    }

    /**
     * @dev Check is ledger is exists
     * @param store Ledgers storage
     * @param addr Ledger address
     * @return bool
     * @notice Throws if address is invalid
     */
    function isLedgerExists(
        LedgersStorage storage store,
        address addr
    ) internal view returns (bool) {
        require(addr != address(0), "ERROR_INVALID_ADDRESS");
        return store.ledgers[addr].addr != address(0);
    }

    /**
     * @dev Returns spandable balance of address
     * @param store Ledgers storage
     * @param addr Ledger address
     * @return bool
     * @notice Throws if ledger is not exists
     */
    function balanceOf(
        LedgersStorage storage store,
        address addr
    ) internal view returns (uint256) {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        return store.ledgers[addr].balance.sub(store.ledgers[addr].blockedFunds);
    }

    /**
     * @dev Returns total balance of address (with blocked funds)
     * @param store Ledgers storage
     * @param addr Ledger address
     * @return bool
     * @notice Throws if ledger is not exists
     */
    function totalBalanceOf(
        LedgersStorage storage store,
        address addr
    ) internal view returns (uint256) {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        return store.ledgers[addr].balance;
    }

    /**
     * @dev Returns total available funds of all ledgers
     * @param store Ledgers storage
     * @return bool
     */
    function totalFunds(LedgersStorage storage store) internal view returns (uint256) {
        uint256 balance = 0;

        for (uint256 i = 0; i <= store.count; i++) {

            if (store.addresses[i] != address(0)) {
                balance = balance.add(balanceOf(store, store.addresses[i]));
            }
        }

        return balance;
    }

    /**
     * @dev Returns total blocked funds of all ledgers
     * @param store Ledgers storage
     * @return bool
     */
    function totalBlockedFunds(LedgersStorage storage store) internal view returns (uint256) {
        uint256 balance = 0;

        for (uint256 i = 0; i <= store.count; i++) {

            if (store.addresses[i] != address(0)) {
                balance = balance.add(store.ledgers[store.addresses[i]].blockedFunds);
            }
        }

        return balance;
    }

    /**
     * @dev Create new ledger record
     * @param store Ledgers storage
     * @param addr Ledger address
     * @notice Throws if address is invalid
     * @notice Throws if ledger for given address already exists
     */
    function put(
        LedgersStorage storage store,
        address addr 
    ) internal {
        require(addr != address(0), "ERROR_INVALID_ADDRESS");
        require(!isLedgerExists(store, addr), "ERROR_LEDGER_ALREADY_EXISTS");
        store.ledgers[addr] = Ledger(addr, 0, 0);
        store.ids[addr] = store.count;
        store.addresses[store.count] = addr;
        store.count += 1;
    }

    /**
     * @dev Deposits amount
     * @param store Ledgers storage
     * @param addr Ledger address
     * @param amount Amount
     * @notice Throws if ledger is not exists
     * @notice Throws if amount is less then minimum amount
     */
    function deposit(
        LedgersStorage storage store,
        address addr,
        uint256 amount
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(amount >= minimumTokensAmount, "ERROR_INVALID_TOKENS_AMOUNT");
        store.ledgers[addr].balance = store.ledgers[addr].balance.add(amount);
    }

    /**
     * @dev Withdraws amount
     * @param store Ledgers storage
     * @param addr Ledger address
     * @param amount Amount
     * @notice Throws if ledger is not exists
     * @notice Throws if spendable balance not enough to withdraw
     */
    function withdraw(
        LedgersStorage storage store,
        address addr,
        uint256 amount
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(balanceOf(store, addr) >= amount, "ERROR_INSUFFICIENT_FUNDS");
        store.ledgers[addr].balance = store.ledgers[addr].balance.sub(amount);
    }

    /**
     * @dev Blocks amount 
     * @param store Ledgers storage
     * @param addr Ledger address
     * @param amount Amount
     * @notice Throws if ledger is not exists
     * @notice Throws if spendable balance not enough to withdraw
     * @notice Throws if amount is less then minimum value
     */
    function blockFunds(
        LedgersStorage storage store,
        address addr,
        uint256 amount
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(balanceOf(store, addr) >= amount, "ERROR_INSUFFICIENT_FUNDS");
        require(amount >= minimumTokensAmount, "ERROR_INVALID_TOKENS_AMOUNT");
        store.ledgers[addr].blockedFunds = store.ledgers[addr].blockedFunds.add(amount);
    }

    /**
     * @dev Unblocks amount 
     * @param store Ledgers storage
     * @param addr Ledger address
     * @param amount Amount 
     * @notice Throws if ledger is not exists
     * @notice Thrpws if insufficient of blocked funds
     * @notice Throws if amount is less then minimum value
     */
    function unblockFunds(
        LedgersStorage storage store,
        address addr,
        uint256 amount
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(store.ledgers[addr].blockedFunds >= amount, "ERROR_INSUFFICIENT_BLOCKED_FUNDS");
        require(amount >= minimumTokensAmount, "ERROR_INVALID_TOKENS_AMOUNT");
        store.ledgers[addr].blockedFunds = store.ledgers[addr].blockedFunds.sub(amount);
    }

    /**
     * @dev Removes ledger
     * @param store Ledgers storage
     * @param addr Ledger address
     * @notice Throws if ledger is not exists
     * @notice Thrpws if ledger has blocked funds
     */
    function remove(
        LedgersStorage storage store,
        address addr
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(store.ledgers[addr].blockedFunds == 0, "ERROR_BLOCKED_FUNDS_FOUND");
        uint256 id = store.ids[addr];
        delete store.ledgers[addr];        
        delete store.ids[addr];
        delete store.addresses[id];
    }
}
