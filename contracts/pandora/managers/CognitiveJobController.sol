pragma solidity ^0.4.24;

import "./ICognitiveJobController.sol";


// Contract implement main cognitive job functionality
contract CognitiveJobController is ICognitiveJobController{

    /*******************************************************************************************************************
     * ## Storage
     */

    enum WorkerResponses {
        Assignment,
        DataValidation,
        Result
    }

    enum States {
        Uninitialized,
        GatheringWorkers,
        InsufficientWorkers,
        DataValidation,
        InvalidData,
        Cognition,
        PartialResult,
        Completed,
        Destroyed
    }

    struct CognitiveJob {
        bytes32 id;
        address kernel;
        address dataset;
        uint256 complexity; //todo find better name
        bytes32 description;
        address[] activeWorkers;
        bytes[] ipfsResults;
        uint32[] responseTimestamps; // time of each worker response
        bool[] responseFlags;
        uint8 progress;
        uint8 state;
    }

    /// @dev Indexes (+1) of active (=running) cognitive jobs in `activeJobs` mapped from their creators
    /// (owners of the corresponding cognitive job contracts). Zero values corresponds to no active job,
    /// one – to the one with index 0 and so forth.
    mapping(bytes32 => uint16) public activeJobsIndexes;

    /// @dev List of all active cognitive jobs
    CognitiveJob[] public activeJobs;

    mapping(bytes32 => uint16) public completedJobsIndexes;

    /// @dev List of all completed cognitive jobs
    CognitiveJob[] public completedJobs;

    ///Table of all possible state transitions
    mapping(uint8 => uint8[]) public transitionTable;

    //        uint8 WORKER_TIMEOUT = 30 minutes;

    constructor() public {
        //state machine initialization should be performed only once with filling transitionTable
        _initStateMachine();
    }

    /******************************************************************************************************************
    Public functions
    */

    /// @dev Returns total count of active jobs
    function activeJobsCount() view public returns (uint256) {
        return activeJobs.length;
    }

    /// @dev Returns total count of active jobs
    function completedJobsCount() view public returns (uint256) {
        return completedJobs.length;
    }

    function getJobId(uint16 _index, bool _isActive)
    view
    public
    returns(bytes32){
        CognitiveJob storage job = _isActive ?
            activeJobs[_index]
            : completedJobs[_index];
        return job.id;
    }

    function getCognitiveJobDetails(bytes32 _jobId)
    external
    view
    returns (
        address kernel,
        address dataset,
        uint256 complexity,
        bytes32 description,
        address[] activeWorkers,
        uint8 progress,
        uint8 state
    ) {
        CognitiveJob storage job = isActiveJob(_jobId) ?
            activeJobs[activeJobsIndexes[_jobId] - 1]
            : completedJobs[completedJobsIndexes[_jobId] - 1];
        kernel = job.kernel;
        dataset = job.dataset;
        complexity = job.complexity;
        description = job.description;
        activeWorkers = job.activeWorkers;
        progress = job.progress;
        state = job.state;
    }

    function getCognitiveJobResults(
        bytes32 _jobId,
        uint8 _index //index of worker, whose results should be returned
    )
    public
    view
    returns(
        bytes ipfsResults
    ) {
        CognitiveJob storage job = isActiveJob(_jobId) ?
            activeJobs[activeJobsIndexes[_jobId] - 1]
            : completedJobs[completedJobsIndexes[_jobId] - 1];
        ipfsResults = job.ipfsResults[_index];
    }

    function getCognitiveJobServiceInfo(
        bytes32 _jobId
    )
    public
    view
    returns(
        uint32[] responseTimestamps,
        bool[] responseFlags
    ) {
        CognitiveJob storage job = isActiveJob(_jobId) ?
            activeJobs[activeJobsIndexes[_jobId] - 1]
            : completedJobs[completedJobsIndexes[_jobId] - 1];
        responseTimestamps = job.responseTimestamps;
        responseFlags = job.responseFlags;
    }

    /******************************************************************************************************************
    External functions (Only Pandora by interface)
    */
    function createCognitiveJob (
        bytes32 _id,
        address _kernel,
        address _dataset,
        address[] _assignedWorkers,
        uint256 _complexity,
        bytes32 _description
    )
    onlyOwner()
    external {
        // The created job must fit into uint16 size
        require(activeJobs.length < uint16(-1));

        activeJobs.push(CognitiveJob({
            id: _id,
            kernel: _kernel,
            dataset: _dataset,
            complexity: _complexity,
            description: _description,
            activeWorkers: _assignedWorkers,
            ipfsResults: new bytes[](_assignedWorkers.length),
            responseTimestamps: new uint32[](_assignedWorkers.length),
            responseFlags: new bool[](_assignedWorkers.length),
            progress: 0,
            state: uint8(States.Uninitialized)
            })
        );
        // Add to addresses map
        activeJobsIndexes[_id] = uint16(activeJobs.length);

        CognitiveJob storage job = activeJobs[activeJobsIndexes[_id] - 1];
        // Init timestamps
        for (uint256 i = 0; i < job.responseTimestamps.length; i++) {
            job.responseTimestamps[i] = uint32(block.timestamp);
        }
        _transitionToState( _id, uint8(States.GatheringWorkers));
        emit WorkersUpdated(_id);
    }

    function respondToJob(
        bytes32 _jobId,
        address _workerId,
        uint8 _responseType,
        bool _response)
    requireActiveStates(_jobId)
    onlyOwner()
    external
    returns (bool result)
    {
        return _onWorkerResponse(_jobId, _workerId, _responseType, _response);
    }

    //should be called for responseTimestamp refresh after actual progress change in workerNode
    //todo implement requirement of new progress > current progress in workerController in new v.
    function commitProgress(
        bytes32 _jobId,
        address _workerId,
        uint8 _percent)
    requireState(_jobId, uint8(States.Cognition))
    onlyOwner()
    external {
        //todo check active worker with workerController
        uint256 workerIndex = _getWorkerIndex( _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job
        activeJobs[activeJobsIndexes[_jobId] - 1].responseTimestamps[workerIndex] = uint32(block.timestamp);
        emit CognitionProgressed(_jobId, _percent);
    }

    /// @notice should be called with provided results
    function completeWork(
        bytes32 _jobId,
        address _workerId,
        bytes _ipfsResults)
    requireState(_jobId, uint8(States.Cognition))
    onlyOwner()
    external
    returns (
        bool result // true - if all workers have submitted result
    ){
        uint256 workerIndex = _getWorkerIndex( _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        activeJobs[activeJobsIndexes[_jobId] - 1].ipfsResults[workerIndex] = _ipfsResults;
        result = _onWorkerResponse( _jobId, _workerId, uint8(WorkerResponses.Result), true);
    }

    //    function reportOfflineWorker(IWorkerNode reported) payable external requireActiveStates;
    //todo should be implemented in workerController in upcoming version

    /******************************************************************************************************************
    Private functions
    */

    /// @dev Could be called from manager with two types of response - Assignment and DataValidation
    function _onWorkerResponse(
        bytes32 _jobId,
        address _workerId,
        uint8 _responseType,
        bool _response)
    private
    returns (bool result)
    {
        _checkResponse( _jobId, _workerId, _responseType, _response);
        // Transition to next state when all workers have responded
        if (_isAllWorkersResponded( _jobId)) {
            result = true;
            if (_responseType == uint8(WorkerResponses.Assignment)) {
                _transitionToState( _jobId, uint8(States.DataValidation));
                //todo implement process decline, with validation in new v.
                _resetAllResponses( _jobId);
            } else if (_responseType == uint8(WorkerResponses.DataValidation)) {
                _transitionToState( _jobId, uint8(States.Cognition));
                //todo implement process decline, with validation in new v.
                _resetAllResponses( _jobId);
            } else if (_responseType == uint8(WorkerResponses.Result)) {
                _transitionToState( _jobId, uint8(States.Completed));
                _onJobComplete(_jobId); // move active job to completed ones
            } else {
                result = false; //not all workers responded
            }
        }
    }

    ///@dev Checks is worker actually computing current job, then updates response's flag and timestamp
    function _checkResponse(
        bytes32 _jobId,
        address _workerId,
        uint8 _responseType,
        bool _response)
    private {
        uint256 workerIndex = _getWorkerIndex( _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        if (_responseType == uint8(WorkerResponses.Assignment)) {
            require(activeJobs[activeJobsIndexes[_jobId] - 1].state == uint8(States.GatheringWorkers));
        } else if (_responseType == uint8(WorkerResponses.DataValidation)) {
            require(activeJobs[activeJobsIndexes[_jobId] - 1].state == uint8(States.DataValidation));
        } else if (_responseType == uint8(WorkerResponses.Result)) {
            require(activeJobs[activeJobsIndexes[_jobId] - 1].state == uint8(States.Cognition));
        }

        //todo implement penalties
        _updateResponse( _jobId, workerIndex, _response);
        _trackOfflineWorkers( _jobId);
    }

    function _getWorkerIndex(
        bytes32 _jobId,
        address _workerId)
    private
    view
    returns (
        uint256
    ) {
        CognitiveJob storage job = activeJobs[activeJobsIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.activeWorkers.length; i++) {
            if (job.activeWorkers[i] == _workerId) {
                return i;
            }
        }
        return uint256(-1);
    }

    function _isAllWorkersResponded(
        bytes32 _jobId)
    private
    view
    returns (
        bool responded
    ) {
        responded = true;
        CognitiveJob storage job = activeJobs[activeJobsIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.responseFlags.length; i++) {
            if (job.responseFlags[i] != true) {
                responded = false;
            }
        }
    }

    function _updateResponse(
        bytes32 _jobId,
        uint256 _workerIndex,
        bool _response)
    private {
        activeJobs[activeJobsIndexes[_jobId] - 1].responseFlags[_workerIndex] = _response;
        activeJobs[activeJobsIndexes[_jobId] - 1].responseTimestamps[_workerIndex] = uint32(block.timestamp);
    }

    ///@dev Reset all response flags and update all timestamps
    function _resetAllResponses(
        bytes32 _jobId)
    private {
        CognitiveJob storage job = activeJobs[activeJobsIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.responseFlags.length; i++) {
            job.responseFlags[i] = false;
            job.responseTimestamps[i] = uint32(block.timestamp);
        }
    }

    //todo provide listener and handle guilty worker and job state in manager, so it could penaltize worker
    function _trackOfflineWorkers(
        bytes32 _jobId)
    requireActiveStates( _jobId)
    internal
    returns (
        address guiltyWorker,
        uint8 jobState
    ){
        CognitiveJob storage job = activeJobs[activeJobsIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.responseTimestamps.length; i++) {
            if (uint8(block.timestamp) - job.responseTimestamps[i] > 30 minutes) {
                guiltyWorker = job.activeWorkers[i];
                jobState = job.state;
            }
        }
    }

    function _onJobComplete(
        bytes32 _jobId)
    private
    {
        completedJobs.push(activeJobs[activeJobsIndexes[_jobId] - 1]);
        completedJobsIndexes[_jobId] = uint8(completedJobs.length);

        if (activeJobsIndexes[_jobId] != activeJobs.length) {
            activeJobs[activeJobsIndexes[_jobId] - 1] = activeJobs[activeJobs.length - 1];
            activeJobsIndexes[activeJobs[activeJobs.length - 1].id] = activeJobsIndexes[_jobId];
        }
        delete activeJobs[activeJobs.length - 1];
        activeJobsIndexes[_jobId] = 0;
        activeJobs.length--;
    }

    /// @dev Checks that job with given id is active or not (tx will fail if job is not existed)
    function isActiveJob(
        bytes32 _jobId
    )
    view
    private
    returns (
        bool
    ) {
        if (activeJobsIndexes[_jobId] != 0) {
            return true;
        } else {
            require(completedJobsIndexes[_jobId] != 0);
            return false;
        }
    }

    /******************************************************************************************************************
    State machine implementation
    */

    modifier requireActiveStates(
        bytes32 _jobId)
    {
        CognitiveJob storage job = activeJobs[activeJobsIndexes[_jobId] - 1];
        require(
            job.state == uint8(States.GatheringWorkers) ||
            job.state == uint8(States.DataValidation) ||
            job.state == uint8(States.Cognition)
        );
        _;
    }

    modifier requireState(
        bytes32 _jobId,
        uint8 requiredState
    ) {
        require(activeJobs[activeJobsIndexes[_jobId] - 1].state == requiredState);
        _;
    }

    modifier requireAllowedTransition(
        bytes32 _jobId,
        uint8 _newState
    ) {
        // Checking if the state transition is allowed
        bool transitionAllowed = false;
        uint8[] storage allowedStates =
            transitionTable[uint8(activeJobs[activeJobsIndexes[_jobId] - 1].state)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _newState) {
                transitionAllowed = true;
            }
        }
        require(transitionAllowed == true);
        _;
    }

    function _transitionToState(
        bytes32 _jobId,
        uint8 _newState)
    requireAllowedTransition( _jobId, _newState)
    private
    {
        CognitiveJob storage job = activeJobs[activeJobsIndexes[_jobId] - 1];
        uint8 oldState = job.state;
        job.state = _newState;
        emit JobStateChanged(_jobId, oldState, job.state);
        _fireStateEvent(_jobId);
    }

    //Fill table of possible state transitions
    function _initStateMachine()
    private {
        mapping(uint8 => uint8[]) transitions = transitionTable;
        transitions[uint8(States.Uninitialized)] =
            [uint8(States.GatheringWorkers)];
        transitions[uint8(States.GatheringWorkers)] =
            [uint8(States.InsufficientWorkers), uint8(States.DataValidation)];
        transitions[uint8(States.DataValidation)] =
            [uint8(States.InvalidData), uint8(States.Cognition), uint8(States.InsufficientWorkers)];
        transitions[uint8(States.Cognition)] =
            [uint8(States.Completed), uint8(States.PartialResult)];
    }

    function _fireStateEvent(
        bytes32 _jobId)
    private {
        uint8 state = activeJobs[activeJobsIndexes[_jobId] - 1].state;
        if (state == uint8(States.InsufficientWorkers)) {
            emit WorkersNotFound(_jobId);
            //_onJobComplete(_jobId); //todo refactor with queue
        } else if (state == uint8(States.DataValidation)) {
            emit DataValidationStarted(_jobId);
        } else if (state == uint8(States.InvalidData)) {
            emit DataValidationFailed(_jobId);
            //_cleanStorage(); //todo refactor
        } else if (state == uint8(States.Cognition)) {
            emit CognitionStarted(_jobId);
        } else if (state == uint8(States.PartialResult)) {
            emit CognitionCompleted(_jobId, true);
        } else if (state == uint8(States.Completed)) {
            emit CognitionCompleted(_jobId, false);
        }
    }
}
