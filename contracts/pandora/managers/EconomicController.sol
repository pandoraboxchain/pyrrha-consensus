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
        emit EconomicInitialized(msg.sender);
    }

    function blockWorkerNodeStake() external {
        blockTokens(minimumWorkerNodeStake);
    }

    function blockWorkerNodeStakeFrom(address from) external {
        blockTokensFrom(from, minimumWorkerNodeStake);
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

    function applyPenalty(
        address workerNodeAddr,
        IWorkerNode.Penalties reason
    ) external onlyPandora {        
        IWorkerNode workerNode = IWorkerNode(workerNodeAddr);
        uint256 penaltyValue;

        if (reason == IWorkerNode.Penalties.OfflineWhileGathering) {
            penaltyValue = workerNode.computingPrice();
        } else if (reason == IWorkerNode.Penalties.DeclinesJob) {
            penaltyValue = workerNode.computingPrice();
        } else if (reason == IWorkerNode.Penalties.OfflineWhileDataValidation) {
            // ???
        } else if (reason == IWorkerNode.Penalties.FalseReportInvalidData) {
            penaltyValue = ledgers.balanceOf(workerNode.owner());// expropriate a whole worker node stake
        } else if (reason == IWorkerNode.Penalties.OfflineWhileCognition) {
            // ???
        } else {
            revert("ERROR_UNKNOWN_PENALTY_REASON");
        }

        if (penaltyValue > 0) {
            _unblock(workerNode.owner(), address(this), penaltyValue);
            workerNode.penalized();
            emit PenaltyApplied(workerNode.owner(), reason, penaltyValue);
        }        
    }

    function makeRewards() external {
        // get maximum worker price: maximumWorkerPrice
        // get job creator: jobCreator
        // get worker nodes owners: workerNodesOwners[]
        // get dataset owner: datasetOwner
        // get kernel owner: kernelOwner
        // get dataset batches count: batchesCount
        // get dataset price: datasetPrice
        // get kernel price: kernelPrice
        // get each worker price: workersPrices[]
        // get system commission value: systemCommission
        
        // calculate total job price: totalJobPrice = datasetPrice + kernelPrice + maximumWorkerPrice * batchesCount
        // calculate tokens amount for mining: tokensMiningAmount = sum(maximumWorkerPrice - workersPrices[i])
        // mint tokensMiningAmount: panToken.mint(tokensMiningAmount, economicController)
        // calculate system commission amount: systemCommissionAmount = totalJobPrice * systemCommission / 10

        // transfer systemCommissionAmount to economicController
        // transfer datasetPrice minus (datasetPrice * systemCommission / 10) to datasetOwner
        // transfer kernelPrice minus (kernelPrice * systemCommission / 10) to kernelOwner
        // transfer maximumWorkerPrice minus (maximumWorkerPrice * systemCommission / 10) to workerNodesOwners[i]
        // clear job creator blocked balance
    }

    function blockTokens(uint256 value) public {
        blockTokensFrom(msg.sender, value);
    }

    function blockTokensFrom(address from, uint256 value) public {
        require(panToken.balanceOf(from) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _block(from, value);
    }

    function unblockTokens(
        address from, 
        address to,
        uint256 value
    ) public onlyPandora {
        _unblock(from, to, value);
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
        emit BlockedTokens(from, value);
    }

    function _unblock(
        address from, 
        address to,
        uint256 value
    ) private onlyInitiazed {
        require(to != address(0), "ERROR_INVALID_ADDRESS");
        panToken.transfer(to, value);
        _sub(from, value);
        emit UnblockedTokens(from, to, value);
    }
}
