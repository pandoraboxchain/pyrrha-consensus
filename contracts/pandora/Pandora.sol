pragma solidity ^0.4.23;

import "../lifecycle/OnlyOnce.sol";
import "./factories/IWorkerNodeFactory.sol";
import "./managers/CognitiveJobManager.sol";
import "./managers/ICognitiveJobController.sol";
import "./token/PAN.sol";

/**
 * @title Pandora Smart Contract
 * @author "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>
 *
 * @dev # Pandora Smart Contract
 *
 * Main & root contract implementing the first level of Pandora Boxchain consensus
 * See section ["3.3. Proof of Cognitive Work (PoCW)" in Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain)
 * for more details.
 *
 * Contract token functionality is separated into a separate contract named PAN (after the name of the token)
 * and Pandora contracts just simply inherits PAN contract.
 */

contract Pandora is OnlyOnce, CognitiveJobManager {

    /*******************************************************************************************************************
     * ## Storage
     */

    /// ### Public variables

    bytes32 public constant version = "0.5.0";


    /*******************************************************************************************************************
     * ## Events
     */


    /*******************************************************************************************************************
     * ## Constructor and initialization
     */

    /// ### Constructor
    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    constructor(
        ICognitiveJobController _jobController,
        IWorkerNodeFactory _nodeFactory, /// Factory class for creating WorkerNode contracts
        IReputation _reputation
    ) public
    CognitiveJobManager(_jobController, _nodeFactory, _reputation)
    // Ensure that the contract is still uninitialized and `initialize` function be called to check the proper
    // setup of class factories
    Initializable()
    Ownable() {
    }

    /// ### Initialization
    /// @notice Function that checks the proper setup of class factories. May be called only once and only by Pandora
    /// contract owner.
    /// @dev Function that checks the proper setup of class factories. May be called only once and only by Pandora
    /// contract owner.
    function initialize()
    public
    onlyOwner
    onlyOnce("initialize") {
        // Checks that the factory contracts creator has assigned Pandora as an owner of the factory contracts:
        // an important security measure preventing "Parity-style" contract bugs
        require(workerNodeFactory.owner() == address(this));

        Initializable.initialize();
    }

    /*******************************************************************************************************************
     * ## Modifiers
     */


    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external
}
