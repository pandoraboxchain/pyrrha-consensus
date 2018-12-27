pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./IEconomicController.sol";
import "./ICognitiveJobManager.sol";
import "../../libraries/LedgersLib.sol";
import "../../nodes/IWorkerNode.sol";


contract EconomicController is IEconomicController, Ownable {

    using LedgersLib for LedgersLib.LedgersStorage;

    /**
     * @dev Internal ledgers storage    
     */
    LedgersLib.LedgersStorage internal ledgers;
    
    IERC20 internal panToken;
    
    ICognitiveJobManager internal pandora;

    modifier onlyInitiazed() {
        require(address(pandora) != address(0), "ERROR_NOT_INITIALIZED");
        _;
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora), "ERROR_NOT_PANDORA_SENDER");
        _;
    }

    constructor (IERC20 _panToken) public {
        panToken = _panToken;        
    }

    function initialize(ICognitiveJobManager _pandora) public {
        require(_pandora != address(0), "ERR0R_INVALID_ADDRESS");
        require(pandora == address(0), "ERROR_ALREADY_INITIALIZED");
        pandora = _pandora;
    }

    function blockWorkerNodeStake() external {
        blockTokens(minimumWorkerNodeStake);
    }

    function hasAvailableFunds(address addr) external view returns (bool) {
        return ledgers.balanceOf(addr) > 0;
    }

    function hasEnoughFunds(address addr, uint256 funds) external view returns (bool) {
        return ledgers.balanceOf(addr) >= funds;
    }

    function positiveWorkerNodeStake(address workerNodeAddr) external view returns (bool) {
        return ledgers.balanceOf(address(IWorkerNode(workerNodeAddr).owner())) > 0;
    }

    function balanceOf(address addr) external view returns (uint256) {
        return ledgers.balanceOf(addr);
    }

    function unblockTokens(
        address from, 
        address to,
        uint256 value
    ) external onlyPandora {
        require(to != address(0), "ERROR_INVALID_ADDRESS");
        panToken.transfer(to, value);
        _sub(from, value);
        emit UnblockedTokens(from, to, value);
    }

    function applyPenalty(
        IWorkerNode.Penalties reason, 
        address owner
    ) external onlyPandora {

        if (reason == IWorkerNode.Penalties.OfflineWhileGathering) {

        } else if (reason == IWorkerNode.Penalties.DeclinesJob) {

        } else if (reason == IWorkerNode.Penalties.OfflineWhileDataValidation) {
            
        } else if (reason == IWorkerNode.Penalties.FalseReportInvalidData) {
            
        } else if (reason == IWorkerNode.Penalties.OfflineWhileCognition) {
            
        } else {
            revert("ERROR_UNKNOWN_PENALTY_REASON");
        }
    }

    function blockTokens(uint256 value) public {
        require(panToken.balanceOf(msg.sender) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _block(msg.sender, value);
    }

    function _add(
        address addr, 
        uint256 value
    ) private onlyInitiazed {

        if (!ledgers.isLedgerExists(addr)) {
            ledgers.put(addr);
        }
        
        ledgers.add(addr, value);
    }

    function _sub(
        address from,
        uint256 value
    ) private onlyInitiazed {
        ledgers.sub(from, value);
    }

    function _block(
        address from,
        uint256 value
    ) private onlyInitiazed {
        panToken.transferFrom(from, address(this), value);
        _add(from, value);
        emit BlockedTokens(msg.sender, value);
    }
}
