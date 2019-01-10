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

/**
 * @title Economic Controller for Pandora
 * @author "Kostiantyn Smyrnov" <kostysh@gmail.com>
 *
 * @dev Economic Controller Smart Contract implementing economic across of Pandora Smart Contract
 */
contract EconomicController is IEconomicController, Ownable {

    // Ledgers storage management library
    using LedgersLib for LedgersLib.LedgersStorage;

    /**
     * @dev Internal ledgers storage    
     * for storing of blocked tokens
     */
    LedgersLib.LedgersStorage internal ledgers;
    
    // Link to the Pan Token contract
    Pan internal panToken;
    
    // Link to the Pandora contract
    Pandora internal pandora;

    // Storage of already processed jobs
    mapping (bytes32 => bool) rewardedJobs;

    /**
     * @dev onlyInitiazed modifier prevents execution of functions if controller not been initialized
     */
    modifier onlyInitiazed() {
        require(address(pandora) != address(0), "ERROR_NOT_INITIALIZED");
        _;
    }

    /**
     * @dev onlyPandora modifier prevents execution of function if sender is not a Pandora contract
     */
    modifier onlyPandora() {
        require(msg.sender == address(pandora), "ERROR_NOT_PANDORA");
        _;
    }

    /**
     * @dev onlyPandora modifier prevents execution of function if sender is not a Pandora 
     * or JobController contract
     */
    modifier onlyPandoraOrJobController() {
        require(msg.sender == address(pandora) || msg.sender == address(pandora.jobController()), "ERROR_NOT_PANDORA_OR_JOB_CONTROLLER");
        _;
    }

    /**
     * @dev EconomicController costructor
     * @param _panToken Pan contract instance
     */
    constructor (Pan _panToken) public {
        panToken = _panToken;// @todo Move panToken initialization to the initialize function
    }

    /**
     * @dev Economic controller initialization
     * @param _pandora Pandora contract instance
     */
    function initialize(Pandora _pandora) public {
        require(_pandora != address(0), "ERR0R_INVALID_ADDRESS");
        require(pandora == address(0), "ERROR_ALREADY_INITIALIZED");
        pandora = _pandora;
        emit EconomicInitialized(msg.sender);
    }

    /**
     * @dev Block tokens of worker node owner
     */
    function blockWorkerNodeStake() external {
        blockTokens(minimumWorkerNodeStake);
    }

    /**
     * @dev Block tokens of specific worker node owner
     * @param from Address of the worker node owner
     */
    function blockWorkerNodeStakeFrom(address from) external {
        blockTokensFrom(from, minimumWorkerNodeStake);
    }

    /**
     * @dev Determine if given address has tokens (blocked) on the intrenal ledger
     * @param addr Address od account
     */
    function hasAvailableFunds(address addr) external view returns (bool) {
        return ledgers.balanceOf(addr) > 0;
    }

    /**
     * @dev Determine if given address has enough blocked funds
     * @param addr Address of account
     * @param funds Amount of tokens
     */
    function hasEnoughFunds(address addr, uint256 funds) external view returns (bool) {
        return ledgers.balanceOf(addr) >= funds;
    }

    /**
     * @dev Determine if specific worker has positive blocked funds balance
     * @param workerNodeAddr Address of the worker node
     */
    function positiveWorkerNodeStake(address workerNodeAddr) external view returns (bool) {
        return ledgers.balanceOf(address(IWorkerNode(workerNodeAddr).owner())) > 0;
    }

    /**
     * @dev Get blocked funds balance for the specific address
     * @param addr Address of the balance owner
     */
    function balanceOf(address addr) external view returns (uint256) {
        return ledgers.balanceOf(addr);
    }

    /**
     * @dev Apply penalty for worker node
     * @param workerNodeAddr Worker node address
     * @param reason Penalty reason
     */
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
            // ??? not implemented yet
        } else if (reason == IWorkerNode.Penalties.FalseReportInvalidData) {
            penaltyValue = ledgers.balanceOf(workerNode.owner());// expropriate a whole worker node stake
        } else if (reason == IWorkerNode.Penalties.OfflineWhileCognition) {
           penaltyValue = workerNode.computingPrice(); 
        } else {
            revert("ERROR_UNKNOWN_PENALTY_REASON");
        }

        if (penaltyValue > 0) {
            _unblock(workerNode.owner(), address(pandora), penaltyValue);
            workerNode.penalized();// Move worker node to the UnderPenalty state
            emit PenaltyApplied(workerNode.owner(), reason, penaltyValue);
        }        
    }

    /**
     * @dev Make rewards for all parties of the job
     * @param _jobId Job Id
     */
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
        uint256 workersDeltaTotal = 0;// accumulator for delta of maximumWorkerPrice and actual workerPrice 

        // transfer rewards to workers
        for (uint256 i = 0; i < activeWorkers.length; i++) {

            priceDelta = 0;
            workerPrice = IWorkerNode(activeWorkers[i]).computingPrice();
            
            if (workerPrice < maximumWorkerPrice) {

                priceDelta = maximumWorkerPrice - workerPrice;
                workersDeltaTotal += priceDelta;
                
                // Reward to the the worker node on base of the actual worker computing price
                _unblock(owner, IWorkerNode(activeWorkers[i]).owner(), workerPrice - (workerPrice / 100 * systemCommission));
                emit RewardTransferred(_jobId, IWorkerNode(activeWorkers[i]).owner(), workerPrice - (workerPrice / 100 * systemCommission));

                // System commission from the workers original price
                _unblock(owner, address(pandora), workerPrice / 100 * systemCommission);
                emit RewardTransferred(_jobId, address(pandora), workerPrice / 100 * systemCommission);

                // Mine missing tokens in count of delta of maximumWorkerPrice and actual workerPrice
                // Mined tokens immidiately transffered as reward to the worker node
                panToken.mint(IWorkerNode(activeWorkers[i]).owner(), priceDelta - (priceDelta / 100 * systemCommission));
                emit TokensMined(_jobId, priceDelta - (priceDelta / 100 * systemCommission));
                emit RewardTransferred(_jobId, IWorkerNode(activeWorkers[i]).owner(), priceDelta - (priceDelta / 100 * systemCommission));
                
                // System commission from the workers mined part
                // Mined tokens immidiately transffered as reward to the system owner (Pandora contract)
                panToken.mint(address(pandora), priceDelta / 100 * systemCommission);
                emit RewardTransferred(_jobId, address(pandora), priceDelta / 100 * systemCommission);
            } else {
                // Reward to the the worker node on base of the maximumWorkerPrice
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

    /**
     * @dev Block tokens from the sender in amount of "value"
     * @param value Amount of tokens to be blocked
     * @notice Amount of tokens should be aproved (pan.approve function) by sender before executing of this function
     */
    function blockTokens(uint256 value) public {
        blockTokensFrom(msg.sender, value);
    }

    /**
     * @dev Block tokens from the specific address in amount of "value"
     * @param from Address of tokens owner
     * @param value Amount of tokens to be blocked
     */
    function blockTokensFrom(address from, uint256 value) public {
        require(panToken.balanceOf(from) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _block(from, value);
    }

    /**
     * @dev Unblock previously blocked tokens from one address and transfer them to another
     * @param from Source address
     * @param to Destination address
     * @param value Amount of tokens to unblock
     * @notice unblockTokens function can be called only by Pandora contract
     */
    function unblockTokens(
        address from, 
        address to,
        uint256 value
    ) public onlyPandora {
        _unblock(from, to, value);
    }

    /**
     * @dev Add (blocked) funds to the address
     * @param addr Destination address
     * @param value Amount of tokens to add
     */
    function _add(
        address addr, 
        uint256 value
    ) private onlyInitiazed {

        if (!ledgers.isLedgerExists(addr)) {
            ledgers.put(addr);
        }
        
        ledgers.add(addr, value);
    }

    /**
     * @dev Block tokens from the address and add funds to the ledger
     * @param from Source address
     * @param value Amount of tokens to block
     */
    function _block(
        address from,
        uint256 value
    ) private onlyInitiazed {
        panToken.transferFrom(from, address(this), value);
        _add(from, value);
        emit BlockedTokens(from, value);
    }

    /**
     * @dev Unblock tokens from the address and transfer them to the destination address
     * @param from Source address
     * @param to Destination address
     * @param value Amount of tokens to unblock
     */
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
