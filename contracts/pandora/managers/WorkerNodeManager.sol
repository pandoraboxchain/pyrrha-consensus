pragma solidity ^0.4.23;

import "../../lifecycle/Initializable.sol";
import "./IWorkerNodeManager.sol";

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

contract WorkerNodeManager is Initializable, Ownable, IWorkerNodeManager {

    /*******************************************************************************************************************
     * ## Storage
     */

    /// ### Public variables

    /// @notice Reference to a factory used in creating WorkerNode contracts
    /// @dev Factories are used to reduce gas consumption by the main Pandora contract. Since Pandora needs to control
    /// the code used to deploy Cognitive Jobs and Worker Nodes, it must embed all the byte code for the smart contract.
    /// However this dramatically increases gas consumption for deploying Pandora contract itself. Thus, the
    /// CognitiveJob smart contract is deployed by a special factory class `CognitiveJobFactory`, and a special workflow
    /// is used to ensure uniqueness of the factories and the fact that their code source is coming from the same
    /// address which have deployed the main Pandora contract. In particular, because of this Pandora is defined as an
    /// `Ownable` contract and a special `initialize` function and `properlyInitialized` member variable is added.
    IWorkerNodeFactory public workerNodeFactory;

    /// @notice List of registered worker nodes
    /// @dev List of registered worker nodes
    IWorkerNode[] public workerNodes;

    /// @notice Index of registered worker nodes by their contract addresses mapping to their index in `workerNodes`.
    /// @dev Index of registered worker nodes by their contract addresses. Used for quick checks instead of
    /// gas-expensive search. Must have the same elements as `workerNodes`. Mapped +1 to the indexes of the contract in
    /// `workerNodes`; zero value is reserved for the removed or non-existing workers.
    /// At any point of time there must be less then 2^16 worker nodes.
    mapping(address => uint16) public workerAddresses;

    /// ### Private and internal variables

    /// @dev Since in the initial Pyrrha release of Pandora network reputation, verification and arbitration mechanics
    /// are under development it uses a set of pre-defined trusted addresses allowed to register worker nodes.
    /// These are specified during initial Pandora contract deployment by the founders.
    mapping(address => bool) public workerNodeOwners;


    /// @dev Event firing when there is another worker node created
    event WorkerNodeCreated(IWorkerNode workerNode);

    /// @dev Event firing when some worker node was destroyed
    event WorkerNodeDestroyed(IWorkerNode workerNode);

    /*******************************************************************************************************************
     * ## Constructor and initialization
     */

    /// ### Constructor
    /// @dev Constructor receives addresses for the owners of whitelisted worker nodes, which will be assigned an owners
    /// of worker nodes contracts
    constructor(
        IWorkerNodeFactory _nodeFactory /// Factory class for creating WorkerNode contracts
    ) public {
        // Must ensure that the supplied factories are already created contracts
        require(_nodeFactory != address(0));

        // Assign factories to storage variables
        workerNodeFactory = _nodeFactory;
    }

    /*******************************************************************************************************************
     * ## Modifiers
     */

    /// @dev Checks that the function is called by the one of the nodes
    modifier onlyWorkerNodes() {
        require(workerAddresses[msg.sender] > 0);
        _;
    }

    /// @dev Checks that the function is called by the owner of one of the whitelisted nodes
    modifier onlyWhitelistedOwners() {
        // Failing if ownership conditions are not satisfied
        require(workerNodeOwners[msg.sender] == true);
        _;
    }

    modifier checkWorkerAndOwner(
        IWorkerNode _workerNode
    ) {
        address nodeOwner = msg.sender;
        require(nodeOwner == address(_workerNode.owner()));
        require(workerAddresses[nodeOwner] > 0);
        _;
    }

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

    /// @notice Adds address to the whitelist of owners allowed to create WorkerNodes contracts
    /// @dev Can be called only by the owner of Pandora contract
    function whitelistWorkerOwner(
        address _workerOwner /// Address for adding to whitelist
    )
    onlyOwner // Only by owner of Pandora contract
    external {
        // Whitelist is organised in a form of mapping with whitelisted addresses set to "true"
        workerNodeOwners[_workerOwner] = true;
    }

    /// @notice Removes address from the whitelist of owners allowed to create WorkerNodes contracts
    /// @dev Can be called only by the owner of Pandora contract
    function blacklistWorkerOwner(
        address _workerOwner /// Address to remove from the whitelist
    )
    onlyOwner
    external {
        // Just simply free the storage
        delete workerNodeOwners[_workerOwner];
    }

    /// @notice Returns count of registered worker nodes
    function workerNodesCount()
    onlyInitialized
    public
    view
    returns (
        uint /// Count of registered worker nodes
    ) {
        return workerNodes.length;
    }

    /// @notice Creates, registers and returns a new worker node owned by the caller of the contract.
    /// Can be called only by the whitelisted node owner address.
    function createWorkerNode()
    external
    onlyInitialized
    onlyWhitelistedOwners
    returns (
        IWorkerNode /// Address of the created worker node
    ) {
        // Worker node can be created only be external transactions, not by internal inter-contract messages
        require(msg.sender == tx.origin);

        /// Check that we do not reach limits in the node count
        require(workerNodes.length < 2 ^ 16 - 1);

        // @todo Check the stake and bind it

        // Creating worker node by using factory. See `properlyInitialized` comments for more details on factories
        IWorkerNode workerNode = workerNodeFactory.create(msg.sender);
        // We do not check the created `workerNode` since all checks are done by the factory class
        workerNodes.push(workerNode);
        // Saving index of the node in the `workerNodes` array (index + 1, zero is reserved for non-existing values)
        workerAddresses[address(workerNode)] = uint16(workerNodes.length);

        // Firing event
        emit WorkerNodeCreated(workerNode);

        return workerNode;
    }

    function penaltizeWorkerNode(
        IWorkerNode _guiltyWorker,
        IWorkerNode.Penalties _reason
    )
    external
        // @fixme Implement the modifier and uncomment
    onlyInitialized {
        /// Can be called only by the assigned cognitive job
        /// @todo Implement penalties from the bound worker node stakes
    }

    /// @notice Removes worker from the workers list and destroys it. Can be called only by the worker node owner
    /// and only for the idle workers
    function destroyWorkerNode(
        IWorkerNode _workerNode
    )
    external
    onlyInitialized {
        /// Can be called only by worker owner
        require(_workerNode.owner() == msg.sender);

        /// Can be called only for the idle workers
        require(_workerNode.currentState() == _workerNode.Idle());

        require(workerAddresses[_workerNode] != 0);

        /// Call worker node destroy function (can be triggered only by this Pandora contract). All balance
        /// is transferred to the node owner.
        /// We do this before removing worker node from the lists since we need to ensure that the node didn"t
        /// got into non-idle state (self-destruct puts node into Destroyed state and it can"t be assigned any
        /// tasks after that)
        _workerNode.destroy();

        /// Immediately removing node from the lists
        uint16 index = workerAddresses[_workerNode] - 1;

        delete workerAddresses[_workerNode];

        if (index != workerNodes.length - 1) {
            IWorkerNode movedWorker = workerNodes[workerNodes.length - 1];
            workerNodes[index] = movedWorker;
            workerAddresses[movedWorker] = index + 1;
        } else {
            delete workerNodes[workerNodes.length - 1];
        }
        workerNodes.length--;

        /// @todo Return the unspent stake

        /// Firing the event
        emit WorkerNodeDestroyed(_workerNode);
    }
}
