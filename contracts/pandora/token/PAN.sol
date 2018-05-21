pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

/**
 * @title PAN Token Contract (Pandora Artificial Neuronetwork Token) for Pyrrha cognitive network
 * @author "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>
 *
 * @dev PAN Tokens is a ERC20-compliant contract, derived from OpenZeppelin StandardToken contract.
 * [Core Pandora contract](Pandora.sol) inherits this contract; so all token-related functionality is removed from it
 * to be placed here.
 *
 * @dev You can read more on PAN Tokens in
 * [Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain),
 * section "2. Economics Models".
 */

contract PAN is StandardToken {
    // ERC20 standard variables
    string public constant name = "Pandora";
    string public constant symbol = "PAN";
    uint public constant decimals = 18;
    uint public totalSupply;

    /// @dev Total token supply is equivalent to the initial supply and does not change with a time (Pyrrha network
    /// does not have cognitive mining). Thus, both initial ant total supply are the pre-mined tokens as described in
    /// the section "2.5. Token Emission" of
    /// [Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain)
    uint public constant INITIAL_SUPPLY = 5000000 * 100000000;

    constructor()
    public
    {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;

        /// @todo Allocate distributed balances to the whitelisted nodes according to the specification
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }
}
