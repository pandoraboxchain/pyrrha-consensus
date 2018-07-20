pragma solidity ^0.4.24;


// Contract implement main cognitive job functionality
library CognitiveJobLib {

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

    struct Controller {
        /// @dev Indexes (+1) of active (=running) cognitive jobs in `activeJobs` mapped from their creators
        /// (owners of the corresponding cognitive job contracts). Zero values corresponds to no active job,
        /// one – to the one with index 0 and so forth.
        mapping(bytes32 => uint16) jobIndexes;

        /// @dev List of all active cognitive jobs
        CognitiveJob[] activeJobs;

        /// @dev List of all completed cognitive jobs
        CognitiveJob[] completedJobs;

        ///Table of all possible state transitions
        mapping(uint8 => uint8[]) transitionTable;

        bool initialized;
//        uint8 WORKER_TIMEOUT = 30 minutes;
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

    /*******************************************************************************************************************
     * ## Functions
     */

    modifier onlyInitialized(Controller storage _self) {
        if (!_self.initialized) {
            _initStateMachine(_self);
        }
        _;
    }

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

    function createCognitiveJob (
        Controller storage _self,
        address _kernel,
        address _dataset,
        address[] _assignedWorkers,
        uint256 _complexity,
        bytes32 _description
    )
    onlyInitialized(_self)
    internal
    returns(
        bytes32 id
    ){
        // The created job must fit into uint16 size
        require(_self.activeJobs.length < uint16(-1));

        id = keccak256(_self.activeJobs.length + block.number);
        _self.activeJobs.push(CognitiveJob({
            id: id,
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
        _self.jobIndexes[id] = uint16(_self.activeJobs.length);

        CognitiveJob storage job = _self.activeJobs[_self.jobIndexes[id] - 1];
        // Init timestamps
        for (uint256 i = 0; i < job.responseTimestamps.length; i++) {
            job.responseTimestamps[i] = uint32(block.timestamp);
        }
        _transitionToState(_self, id, uint8(States.GatheringWorkers));
        emit WorkersUpdated(id);
    }

    /// @dev Could be called from manager with two types of response - Assignment and DataValidation
    function onWorkerResponse(
        Controller storage _self,
        bytes32 _jobId,
        address _workerId,
        uint8 _responseType,
        bool _response)
    onlyInitialized(_self)
    requireActiveStates(_self, _jobId)
    internal
    returns (bool result)
    {
        _checkResponse(_self, _jobId, _workerId, _response);
        // Transition to next state when all workers have responded
        if (_isAllWorkersResponded(_self, _jobId)) {
            result = true;
            if (_responseType == uint8(WorkerResponses.Assignment)) {
                _transitionToState(_self, _jobId, uint8(States.GatheringWorkers));
                //todo implement process decline, with validation in new v.
                _resetAllResponses(_self, _jobId);
            } else if (_responseType == uint8(WorkerResponses.DataValidation)) {
                _transitionToState(_self, _jobId, uint8(States.Cognition));
                //todo implement process decline, with validation in new v.
                _resetAllResponses(_self, _jobId);
            } else if (_responseType == uint8(WorkerResponses.Result)) {
                _transitionToState(_self, _jobId, uint8(States.Completed));
            } else {
                result = false; //not all workers responded
            }
        }
    }

    //should be called for responseTimestamp refresh after actual progress change in workerNode
    //todo implement requirement of new progress > current progress in workerController in new v.
    function commitProgress(
        Controller storage _self,
        bytes32 _jobId,
        address _workerId,
        uint8 _percent)
    onlyInitialized(_self)
    requireState(_self, _jobId, uint8(States.Cognition))
    internal {
        //todo check active worker with workerController
        uint256 workerIndex = _getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job
        _self.activeJobs[_self.jobIndexes[_jobId] - 1].responseTimestamps[workerIndex] = uint32(block.timestamp);
        emit CognitionProgressed(_jobId, _percent);
    }

    /// @notice should be called with provided results
    function completeWork(
        Controller storage _self,
        bytes32 _jobId,
        address _workerId,
        bytes _ipfsResults)
    onlyInitialized(_self)
    requireState(_self, _jobId, uint8(States.Cognition))
    internal
    returns (
        bool result // true - if all workers have submitted result
    ){
        uint256 workerIndex = _getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        _self.activeJobs[_self.jobIndexes[_jobId] - 1].ipfsResults[workerIndex] = _ipfsResults;
        result = onWorkerResponse(_self, _jobId, _workerId, uint8(WorkerResponses.Result), true);
        //todo move to completed jobs
    }

    //    function reportOfflineWorker(IWorkerNode reported) payable external requireActiveStates;
    //todo should be implemented in workerController in upcoming version

    /******************************************************************************************************************
    Private functions
    */

    ///@dev Checks is worker actually computing current job, then updates response's flag and timestamp
    function _checkResponse(
        Controller storage _self,
        bytes32 _jobId,
        address _workerId,
        bool _response)
    onlyInitialized(_self)
    private {
        uint256 workerIndex = _getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        //todo implement penalties
        _updateResponse(_self, _jobId, workerIndex, _response);
        _trackOfflineWorkers(_self, _jobId);
    }

    function _getWorkerIndex(
        Controller storage _self,
        bytes32 _jobId,
        address _workerId)
    onlyInitialized(_self)
    private
    view
    returns (
        uint256
    ) {
        CognitiveJob storage job = _self.activeJobs[_self.jobIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.activeWorkers.length; i++) {
            if (job.activeWorkers[i] == _workerId) {
                return i;
            }
        }
        return uint256(-1);
    }

    function _isAllWorkersResponded(
        Controller storage _self,
        bytes32 _jobId)
    onlyInitialized(_self)
    private
    view
    returns (
        bool responded
    ) {
        responded = true;
        CognitiveJob storage job = _self.activeJobs[_self.jobIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.responseFlags.length; i++) {
            if (job.responseFlags[i] != true) {
                responded = false;
            }
        }
    }

    function _updateResponse(
        Controller storage _self,
        bytes32 _jobId,
        uint256 _workerIndex,
        bool _response)
    onlyInitialized(_self)
    private {
        _self.activeJobs[_self.jobIndexes[_jobId] - 1].responseFlags[_workerIndex] = _response;
        _self.activeJobs[_self.jobIndexes[_jobId] - 1].responseTimestamps[_workerIndex] = uint32(block.timestamp);
    }

    ///@dev Reset all response flags and update all timestamps
    function _resetAllResponses(
        Controller storage _self,
        bytes32 _jobId)
    onlyInitialized(_self)
    private {
        CognitiveJob storage job = _self.activeJobs[_self.jobIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.responseFlags.length; i++) {
            job.responseFlags[i] = false;
            job.responseTimestamps[i] = uint32(block.timestamp);
        }
    }

    //todo provide listener and handle guilty worker and job state in manager, so it could penaltize worker
    function _trackOfflineWorkers(
        Controller storage _self,
        bytes32 _jobId)
    onlyInitialized(_self)
    requireActiveStates(_self, _jobId)
    internal
    returns (
        address guiltyWorker,
        uint8 jobState
    ){
        CognitiveJob storage job = _self.activeJobs[_self.jobIndexes[_jobId] - 1];
        for (uint256 i = 0; i < job.responseTimestamps.length; i++) {
            if (uint8(block.timestamp) - job.responseTimestamps[i] > 30 minutes) {
                guiltyWorker = job.activeWorkers[i];
                jobState = job.state;
            }
        }
    }

    /******************************************************************************************************************
    State machine implementation
    */

    modifier requireActiveStates(
        Controller storage _self,
        bytes32 _jobId)
    {
        CognitiveJob storage job = _self.activeJobs[_self.jobIndexes[_jobId] - 1];
        require(
            job.state == uint8(States.GatheringWorkers) ||
            job.state == uint8(States.DataValidation) ||
            job.state == uint8(States.Cognition)
        );
        _;
    }

    modifier requireState(
        Controller storage _self,
        bytes32 _jobId,
        uint8 requiredState
    ) {
        require(_self.activeJobs[_self.jobIndexes[_jobId] - 1].state == requiredState);
        _;
    }

    modifier requireAllowedTransition(
        Controller storage _self,
        bytes32 _jobId,
        uint8 _newState
    ) {
        // Checking if the state transition is allowed
        bool transitionAllowed = false;
        uint8[] storage allowedStates =
            _self.transitionTable[uint8(_self.activeJobs[_self.jobIndexes[_jobId] - 1].state)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _newState) {
                transitionAllowed = true;
            }
        }
        require(transitionAllowed == true);
        _;
    }

    function _transitionToState(
        Controller storage _self,
        bytes32 _jobId,
        uint8 _newState)
    onlyInitialized(_self)
    requireAllowedTransition(_self, _jobId, _newState)
    private
    {
        CognitiveJob storage job = _self.activeJobs[_self.jobIndexes[_jobId] - 1];
        uint8 oldState = job.state;
        job.state = _newState;
        emit JobStateChanged(_jobId, oldState, job.state);
        _fireStateEvent(_self, _jobId);
    }

    //Fill table of possible state transitions
    function _initStateMachine(
        Controller storage _self)
    private {
        mapping(uint8 => uint8[]) transitions = _self.transitionTable;
        transitions[uint8(States.Uninitialized)] =
            [uint8(States.GatheringWorkers)];
        transitions[uint8(States.GatheringWorkers)] =
            [uint8(States.InsufficientWorkers), uint8(States.DataValidation)];
        transitions[uint8(States.DataValidation)] =
            [uint8(States.InvalidData), uint8(States.Cognition), uint8(States.InsufficientWorkers)];
        transitions[uint8(States.Cognition)] =
            [uint8(States.Completed), uint8(States.PartialResult)];
        _self.initialized = true;
    }

    function _fireStateEvent(
        Controller storage _self,
        bytes32 _jobId)
    onlyInitialized(_self)
    private {
        uint8 state = _self.activeJobs[_self.jobIndexes[_jobId] - 1].state;
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
//            pandora.finishCognitiveJob();
        } else if (state == uint8(States.Completed)) {
            emit CognitionCompleted(_jobId, false);
//            pandora.finishCognitiveJob();
              _onJobComplete(_self, _jobId);
        }
    }

    function _onJobComplete(
        Controller storage _self,
        bytes32 _jobId)
    onlyInitialized(_self)
    private
    {
        //todo implement
    }

    /******************************************************************************************************************
     * ## Events
     */

    //todo 'indexed' should be removed from lib
    event JobStateChanged(bytes32 indexed jobId, uint8 oldState, uint8 newState);
    event WorkersUpdated(bytes32 indexed jobId);
    event WorkersNotFound(bytes32 indexed jobId);
    event DataValidationStarted(bytes32 indexed jobId);
    event DataValidationFailed(bytes32 indexed jobId);
    event CognitionStarted(bytes32 indexed jobId);
    event CognitionProgressed(bytes32 indexed jobId, uint8 precent);
    event CognitionCompleted(bytes32 indexed jobId, bool partialResult);
}
