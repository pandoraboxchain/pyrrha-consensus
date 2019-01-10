pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../token/Pan.sol";
import "./IEconomicController.sol";
import "./ICognitiveJobController.sol";
import "../Pandora.sol";
import "../../libraries/LedgersLib.sol";
import "../../nodes/IWorkerNode.sol";
import "../../entities/IDataset.sol";
import "../../entities/IKernel.sol";


contract EconomicController is IEconomicController, Ownable {

    using LedgersLib for LedgersLib.LedgersStorage;

    /**
     * @dev Internal ledgers storage    
     */
    LedgersLib.LedgersStorage internal ledgers;
    
    Pan internal panToken;
    
    Pandora internal pandora;

    mapping (bytes32 => bool) rewardedJobs;

    modifier onlyInitiazed() {
        require(address(pandora) != address(0), "ERROR_NOT_INITIALIZED");
        _;
    }

    modifier onlyPandora() {
        require(msg.sender == address(pandora), "ERROR_NOT_PANDORA");
        _;
    }

    modifier onlyPandoraOrJobController() {
        require(msg.sender == address(pandora) || msg.sender == address(pandora.jobController()), "ERROR_NOT_PANDORA_OR_JOB_CONTROLLER");
        _;
    }

    constructor (Pan _panToken) public {
        panToken = _panToken;        
    }

    function initialize(Pandora _pandora) public {
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
    ) external onlyInitiazed onlyPandoraOrJobController {        
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
           penaltyValue = workerNode.computingPrice(); 
        } else {
            revert("ERROR_UNKNOWN_PENALTY_REASON");
        }

        if (penaltyValue > 0) {
            _unblock(workerNode.owner(), address(pandora), penaltyValue);
            workerNode.penalized();
            emit PenaltyApplied(workerNode.owner(), reason, penaltyValue);
        }        
    }

    function makeRewards(bytes32 _jobId) external onlyInitiazed onlyPandoraOrJobController {
        // get job 
        (address owner, address kernel, address dataset, , , address[] memory activeWorkers, , uint8 state) = (pandora.jobController()).getCognitiveJobDetails(_jobId);

        require(!rewardedJobs[_jobId], "ERROR_JOB_ALREADY_REWARDED");
        require(state == uint8(ICognitiveJobController.States.Completed), "ERROR_WRONG_JOB_STATE_FOR_REWARDS");

        // save link to prevent double rewards
        rewardedJobs[_jobId] = true;
        
        // get maximum worker price
        uint256 maximumWorkerPrice = pandora.getMaximumWorkerPrice();

        // get dataset and kernel price
        uint256 datasetPrice = IDataset(dataset).currentPrice();
        uint256 kernelPrice = IKernel(kernel).currentPrice();

        // transfer datasetOwner reward
        _unblock(owner, IDataset(dataset).owner(), datasetPrice - (datasetPrice / 100 * systemCommission));
        emit RewardTransferred(_jobId, IDataset(dataset).owner(), datasetPrice - (datasetPrice / 100 * systemCommission));

        // system commission from dataset
        _unblock(owner, address(pandora), datasetPrice / 100 * systemCommission);
        emit RewardTransferred(_jobId, address(pandora), datasetPrice / 100 * systemCommission);

        // transfer kernelOwner reward
        _unblock(owner, IKernel(kernel).owner(), kernelPrice - (kernelPrice / 100 * systemCommission));
        emit RewardTransferred(_jobId, IKernel(kernel).owner(), kernelPrice - (kernelPrice / 100 * systemCommission));

        // system commission from kernel
        _unblock(owner, address(pandora), kernelPrice / 100 * systemCommission);
        emit RewardTransferred(_jobId, address(pandora), kernelPrice / 100 * systemCommission);

        uint256 workerPrice;
        uint256 priceDelta;
        uint256 workersDeltaTotal = 0;

        // transfer rewards to workers
        for (uint256 i = 0; i < activeWorkers.length; i++) {

            priceDelta = 0;
            workerPrice = IWorkerNode(activeWorkers[i]).computingPrice();
            
            if (workerPrice < maximumWorkerPrice) {

                priceDelta = maximumWorkerPrice - workerPrice;
                workersDeltaTotal += priceDelta;
                
                _unblock(owner, IWorkerNode(activeWorkers[i]).owner(), workerPrice - (workerPrice / 100 * systemCommission));
                emit RewardTransferred(_jobId, IWorkerNode(activeWorkers[i]).owner(), workerPrice - (workerPrice / 100 * systemCommission));

                // System commission from the workers original price
                _unblock(owner, address(pandora), workerPrice / 100 * systemCommission);
                emit RewardTransferred(_jobId, address(pandora), workerPrice / 100 * systemCommission);

                // Mine missing tokens
                panToken.mint(IWorkerNode(activeWorkers[i]).owner(), priceDelta - (priceDelta / 100 * systemCommission));
                emit TokensMined(_jobId, priceDelta - (priceDelta / 100 * systemCommission));
                emit RewardTransferred(_jobId, IWorkerNode(activeWorkers[i]).owner(), priceDelta - (priceDelta / 100 * systemCommission));
                
                // System commission from the workers mined part
                panToken.mint(address(pandora), priceDelta / 100 * systemCommission);
                emit RewardTransferred(_jobId, address(pandora), priceDelta / 100 * systemCommission);
            } else {
                _unblock(owner, IWorkerNode(activeWorkers[i]).owner(), maximumWorkerPrice - (maximumWorkerPrice / 100 * systemCommission));
                emit RewardTransferred(_jobId, IWorkerNode(activeWorkers[i]).owner(), maximumWorkerPrice - (maximumWorkerPrice / 100 * systemCommission));

                // system commission from worker
                _unblock(owner, address(pandora), maximumWorkerPrice / 100 * systemCommission);
                emit RewardTransferred(_jobId, address(pandora), maximumWorkerPrice / 100 * systemCommission);
            }
        }

        if (workersDeltaTotal > 0) {
            // Refund workers price delta to the job owner
            _unblock(owner, owner, workersDeltaTotal);
            emit RefundedDelta(_jobId, owner, workersDeltaTotal);
        }
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
        ledgers.sub(from, value);
        emit UnblockedTokens(from, to, value);
    }
}
