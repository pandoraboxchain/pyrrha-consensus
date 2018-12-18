pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title LedgersLib
 * @dev This library hold a tokens management logic
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 */
library LedgersLib {

    using SafeMath for uint256;

    uint256 private constant minimumTokensValue = 1;

    struct Ledger {
        address addr;
        uint256 balance;
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
        return store.ledgers[addr].balance;
    }

    /**
     * @dev Returns total available funds of all ledgers
     * @param store Ledgers storage
     * @return bool
     */
    function totalBalance(LedgersStorage storage store) internal view returns (uint256) {
        uint256 balance = 0;

        for (uint256 i = 0; i <= store.count; i++) {

            if (store.addresses[i] != address(0)) {
                balance = balance.add(balanceOf(store, store.addresses[i]));
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
        store.ledgers[addr] = Ledger(addr, 0);
        store.ids[addr] = store.count;
        store.addresses[store.count] = addr;
        store.count += 1;
    }

    /**
     * @dev Removes ledger
     * @param store Ledgers storage
     * @param addr Ledger address
     * @notice Throws if ledger is not exists
     * @notice Thrpws if ledger has positive balance
     */
    function remove(
        LedgersStorage storage store,
        address addr
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(store.ledgers[addr].balance == 0, "ERROR_POSITIVE_BALANCE");
        uint256 id = store.ids[addr];
        delete store.ledgers[addr];        
        delete store.ids[addr];
        delete store.addresses[id];
    }

    /**
     * @dev Add value to address
     * @param store Ledgers storage
     * @param addr Ledger address
     * @param value Value
     * @notice Throws if ledger is not exists
     * @notice Throws if value is less then minimum value
     */
    function add(
        LedgersStorage storage store,
        address addr,
        uint256 value
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(value >= minimumTokensValue, "ERROR_INVALID_TOKENS_AMOUNT");
        store.ledgers[addr].balance = store.ledgers[addr].balance.add(value);
    }

    /**
     * @dev Subtract value from address balance
     * @param store Ledgers storage
     * @param addr Ledger address
     * @param value Value
     * @notice Throws if ledger is not exists
     * @notice Throws if spendable balance not enough to withdraw
     */
    function sub(
        LedgersStorage storage store,
        address addr,
        uint256 value
    ) internal {
        require(isLedgerExists(store, addr), "ERROR_LEDGER_NOT_EXISTS");
        require(balanceOf(store, addr) >= value, "ERROR_INSUFFICIENT_FUNDS");
        store.ledgers[addr].balance = store.ledgers[addr].balance.sub(value);
    }    
}
