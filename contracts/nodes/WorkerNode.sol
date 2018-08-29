pragma solidity ^0.4.23;

import "../libraries/StateMachine.sol";
import "../pandora/managers/ICognitiveJobManager.sol";
import "./IWorkerNode.sol";

/**
 * @title Worker Node Smart Contract
 * @author "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>
 *
 * @dev # Worker Node Smart Contract
 *
 * Worker node contract accumulates funds/payments for performed cognitive work and contains inalienable reputation.
 * Note: In Pyrrha there is no mining. In the following versions all mined coins will be also assigned to the
 * `WorkerNode` contract
 *
 * Worker node acts as a state machine and each its function can be evoked only in some certain states. That"s
 * why each function must have state machine-controlled function modifiers. Contract state is managed by
 * - Worker node code (second level of consensus)
 * - Main Pandora contract [Pandora.sol]
 * - Worker node contract itself
 */

contract WorkerNode is IWorkerNode, StateMachine   /* final */ {
    /**
     * ## State Machine extensions
     */

    /// @dev Modifier requiring contract to be preset in one of the active states (`Assigned`, `ReadyForDataValidation`,
    /// `ValidatingData`, `ReadyForComputing`, `Computing`); otherwise an exception is generated and the function
    /// does not execute
    modifier requireActiveStates() {
        require(
            stateMachine.currentState == Assigned ||
            stateMachine.currentState == ReadyForDataValidation ||
            stateMachine.currentState == ValidatingData ||
            stateMachine.currentState == ReadyForComputing ||
            stateMachine.currentState == Computing);
        _;
    }

    /// @dev Private method initializing state machine. Must be called only once from the contract constructor
    function _initStateMachine() internal {
        // Creating table of possible state transitions
        mapping(uint8 => uint8[]) transitions = stateMachine.transitionTable;
        transitions[Uninitialized] = [Idle, Offline, InsufficientStake];
        transitions[Offline] = [Idle];
        transitions[Idle] = [Offline, UnderPenalty, Assigned, Destroyed];
        transitions[Assigned] = [Offline, UnderPenalty, ReadyForDataValidation];
        transitions[ReadyForDataValidation] = [ValidatingData, Offline, UnderPenalty, Idle];
        transitions[UnderPenalty] = [Offline, InsufficientStake, Idle];
        transitions[ValidatingData] = [Offline, Idle, UnderPenalty, ReadyForComputing];
        transitions[ReadyForComputing] = [Computing, Offline, UnderPenalty, Idle];
        transitions[Computing] = [Offline, UnderPenalty, Idle];
        transitions[InsufficientStake] = [Offline, Idle, Destroyed];

        // Initializing state machine via base contract code
        super._initStateMachine();

        // Going into initial state (Offline)
        stateMachine.currentState = Offline;
    }

    /**
     * ## Main implementation
     */

    /// ### Public variables


    /// @notice Reference to the main Pandora contract.
    /// @dev Required to check the validity of the method calls coming from the Pandora contract.
    /// Initialy set from the address supplied to the constructor and can"t be changed after.
    ICognitiveJobManager public pandora;

    /// @notice Active cognitive job reference. Zero when there is no active cognitive job assigned or performed
    /// @dev Valid (non-zero) only for active states (see `activeStates` modified for the list of such states)
    bytes32 public activeJob;

	/// @notice Progress of completing current active job batch, should be updated by node itself
    uint256 public jobProgress;

    event WorkerDestroyed();

    /// ### Constructor and destructor

    constructor(
        ICognitiveJobManager _pandora /// Reference to the main Pandora contract that creates Worker Node
    )
    public {
        require(_pandora != address(0));
        pandora = _pandora;

        // Initialize state machine (state transition table and initial state). Always must be performed at the very
        // end of contract constructor code.
        _initStateMachine();
    }

    /// ### Function modifiers

    /// @dev Modifier for functions that can be called only by the main Pandora contract
    modifier onlyPandora() {
        require(msg.sender == address(pandora));
        _;
    }

    /// ### External and public functions

    function destroy()
        external
        onlyPandora
    {
        /// Call event before doing the actual contract suicide
        emit WorkerDestroyed();

        /// Suiciding
        selfdestruct(owner);
    }

    function alive() external
        onlyOwner
        requireState(Offline)
    {
        _transitionToState(Idle);
    }

    function reportProgress(uint8 _percent) external
        onlyOwner
    {
        jobProgress = _percent;
        pandora.commitProgress(activeJob, _percent);
    }

    /// @notice Do not call
    /// @dev Assigns cognitive job to the worker. Can be called only by one of active cognitive jobs listed under
    /// the main Pandora contract
    function assignJob(
        /// @dev Cognitive job to be assigned
        bytes32 _jobId

    )
    onlyPandora
    external
        /// @dev Job can be assigned only to Idle workers
        requireState(Idle)
    {
        activeJob = _jobId;
        jobProgress = 0;
        _transitionToState(Assigned);
    }

    function cancelJob()
        onlyPandora
        requireActiveStates
        external
    {
        activeJob = bytes32(0);
        _transitionToState(Idle);
    }

    function acceptAssignment() external
        onlyOwner
        requireState(Assigned)
    {
        require(activeJob != bytes32(0));
        pandora.respondToJob(activeJob, 0, true); // 0 - response type AcceptAssignment
        _transitionToState(ReadyForDataValidation);
    }

    function declineAssignment() external
        onlyOwner
        requireState(Assigned)
    {
        require(activeJob != bytes32(0));
        pandora.respondToJob(activeJob, 0, false); // 0 - response type AcceptAssignment
        _transitionToState(Idle);
    }

    function processToDataValidation() external
        onlyOwner
        requireState(ReadyForDataValidation)
    {
        _transitionToState(ValidatingData);
    }

    function acceptValidData() external
        onlyOwner
        requireState(ValidatingData)
    {
        require(activeJob != bytes32(0));
        pandora.respondToJob(activeJob, 1, true); // 1 - response type DataValidation
        _transitionToState(ReadyForComputing);
    }

    function declineValidData() external
        onlyOwner
        requireState(ValidatingData)
    {
        require(activeJob != bytes32(0));
        pandora.respondToJob(activeJob, 1, false);  // 1 - response type DataValidation
        _transitionToState(Idle);
    }

    function reportInvalidData() external
        onlyOwner
        requireState(ValidatingData)
    {
        require(activeJob != bytes32(0));
        //todo implement with validation
        _transitionToState(Idle);
    }

    function processToCognition() external
        onlyOwner
        requireState(ReadyForComputing)
    {
        _transitionToState(Computing);
    }

    function provideResults(
        bytes _ipfsAddress
    ) external
        onlyOwner
        requireState(Computing)
    {
        require(activeJob != bytes32(0));
        pandora.provideResults(activeJob, _ipfsAddress);
        _transitionToState(Idle);
    }

    /// @notice Withdraws full balance to the owner account. Can be called only by the owner of the contract.
    function withdrawBalance() external
        onlyOwner // Can be called only by the owner
        requireStates2(Idle, Offline)
    {
        owner.transfer(address(this).balance);
    }

    function _transitionToState(uint8 _newState) private requireAllowedTransition(_newState)  {
        transitionToState(_newState);
    }
}
