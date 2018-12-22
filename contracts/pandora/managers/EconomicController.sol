pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./IEconomicController.sol";
import "../../libraries/LedgersLib.sol";
import "../../nodes/IWorkerNode.sol";


contract EconomicController is IEconomicController, Ownable {

    using LedgersLib for LedgersLib.LedgersStorage;

    /**
     * @dev Internal ledgers storage    
     */
    LedgersLib.LedgersStorage internal ledgers;

    function add(address addr, uint256 value) external onlyOwner {

        if (!ledgers.isLedgerExists(addr)) {
            ledgers.put(addr);
        }
        
        ledgers.add(addr, value);
    }

    function sub(
        address from,
        uint256 value
    ) external onlyOwner {
        ledgers.sub(from, value);
    }

    function balanceOf(address addr) external view returns (uint256) {
        return ledgers.balanceOf(addr);
    }

    function addFrom(
        address from,
        uint256 value
    ) external onlyOwner {

        if (!ledgers.isLedgerExists(from)) {
            ledgers.put(from);
        }
        
        ledgers.add(from, value);
    }

    function positiveWorkerNodeStake(address workerNodeAddr) external view returns (bool) {
        return ledgers.balanceOf(address(IWorkerNode(workerNodeAddr).owner())) > 0;
    }
}
