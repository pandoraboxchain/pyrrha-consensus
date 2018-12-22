pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "../../lifecycle/FeatureInitializable.sol";
import "../managers/IEconomicManager.sol";
import "../managers/IEconomicController.sol";


/**
 * @title PAN Token Contract (Pandora Artificial Neuronetwork Token) for Pyrrha cognitive network
 * @author Kostiantyn Smyrnov <kostysh@gmail.com>
 *
 * @dev PAN Tokens is a ERC20-compliant contract, derived from OpenZeppelin StandardToken contract.
 * [Core Pandora contract](Pandora.sol) inherits this contract; so all token-related functionality is removed from it
 * to be placed here.
 *
 * @dev You can read more on PAN Tokens in
 * [Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain),
 * section "2. Economics Models".
 * 
 * @dev Total token supply is equivalent to the initial supply and does not change with a time (Pyrrha network
 * does not have cognitive mining). Thus, both initial ant total supply are the pre-mined tokens as described in
 * the section "2.5. Token Emission" of
 * [Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain)
 */
contract Pan is ERC20, MinterRole, FeatureInitializable, IEconomicManager {

    string public constant name = "Pandora AI Network Token";
    string public constant symbol = "PAN";
    uint public constant decimals = 18;

    // Controller for economic related functions
    IEconomicController public economicController;
    
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
        address indexed from,
        address indexed to,
        uint256 value
    );

    /**
     * @dev This event will be emitted every time a penalty been applied to the stake owner
     * @param owner Stake owner address
     * @param value Penalty value
     */
    event PenaltyApplied(
        IWorkerNode.Penalties reason,
        address indexed owner,
        uint256 value
    );

    /**
     * @dev Throws if called not initialized feature
     */
    modifier mintableInitialized() {
        require(isFeatureInitialized(keccak256("mintable")), "ERROR_MINTABLE_FEATURE_NOT_INITIALIZED");
        _;
    }

    constructor (IEconomicController _economicController) {
        economicController = _economicController;
    }
    
    /**
     * @dev Initializing of mintable feature
     * @param _minter Minter address
     */
    function initializeMintable(address _minter) public {
        require(_minter != address(0), "ERROR_INVALID_ADDRESS");
        _setFeatureInitialized(keccak256("mintable"));

        if (!isMinter(_minter)) {
            _addMinter(_minter);
        }        
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(
        address to,
        uint256 value
    ) public mintableInitialized onlyMinter returns(bool) {
        _mint(to, value);
        return true;
    }

    function blockTokens(uint256 value) public {
        require(balanceOf(msg.sender) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _transfer(msg.sender, address(this), value);
        economicController.add(msg.sender, value);
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
        economicController.sub(from, value);
        _transfer(address(this), to, value);
        emit UnblockedTokens(from, to, value);
    }

    function hasAvailableFunds(address addr) public view returns (bool) {
        return economicController.balanceOf(addr) > 0;
    }

    function hasEnoughFunds(address addr, uint256 funds) public view returns (bool) {
        return economicController.balanceOf(addr) >= funds;
    }

    function hasWorkerNodeAvailableFunds(address workerNodeAddr) public view returns (bool) {
        return economicController.positiveWorkerNodeStake(workerNodeAddr);
    }

    function getAvailableBalance(address addr) public view returns (uint256) {
        return economicController.balanceOf(addr);
    }

    function blockTokensFrom(
        address from,
        uint256 value
    ) internal {
        require(balanceOf(from) >= value, "ERROR_INSUFFICIENT_TOKENS");
        _transfer(from, address(this), value);
        economicController.addFrom(from, value);
        emit BlockedTokens(from, value);
    }
}
