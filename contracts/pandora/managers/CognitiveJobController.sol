pragma solidity ^0.4.23;


// Contract implement main cognitive job functionality
library CognitiveJobController {

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
        mapping(bytes32 => uint256) jobAddresses;

        /// @dev List of all active cognitive jobs
        CognitiveJob[] cognitiveJobs;

        mapping(uint8 => uint8[]) transitionTable;

//        uint8 WORKER_TIMEOUT = 30 minutes;
    }

    struct CognitiveJob {
        bytes32 id;
        bytes32 kernel;
        bytes32 dataset;
        uint256 complexity; //todo find better name
        bytes32 description;
        bytes32[] activeWorkers;
        bytes[] ipfsResults;
        uint32[] responseTimestamps; // time of each worker response
        bool[] responseFlags;
        uint8 progress;
        uint8 state;
    }

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

    //todo move to manager
    function getCognitiveJobDetails(Controller _self, bytes32 _jobId)
    public
    returns (
        bytes32, bytes32, uint256, bytes32, bytes32[], bytes[]
    ) {
        CognitiveJob job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        return (
            job.kernel,
            job.dataset,
            job.complexity,
            job.description,
            job.activeWorkers,
            job.ipfsResults
        );
    }

    //todo move to manager
    function getCognitiveJobProgressInfo(bytes32 _jobId)
    public
    returns(
        uint32[], bool[], uint8, uint8
    ) {
        CognitiveJob job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        return (
            job.responseTimestamps,
            job.responseFlags,
            job.progress,
            job.state
        );
    }

    function createCognitiveJob (
        Controller _self,
        bytes32 _kernel,
        bytes32 _dataset,
        bytes32[] _assignedWorkers,
        uint256 _complexity,
        bytes32 _description
    )
    internal {
        CognitiveJob job = CognitiveJob({
            id: keccak256(_self.cognitiveJobs.length + block.number),
            kernel: _kernel,
            dataset: _dateset,
            complexity: _complexity,
            description: _description,
            activeWorkers: _assignedWorkers,
            ipfsResults: new bytes[](_assignedWorkers.length),
            responseTimestamps: new uint[](_assignedWorkers.length),
            responseFlags: new bool[](_assignedWorkers.length),
            progress: 0
            });
        //init timestamps
        for (uint256 i = 0; job.responseTimestamps.length; i++) {
            job.responseTimestamps[i] = block.timestamp;
        }
        //add to register newly created job
        _self.cognitiveJobs.push(job);
        _self.jobAddresses[job.id] = uint256(cognitiveJobs.length);

        //todo switch to state gathering
        //        _transitionToState(GatheringWorkers);
        emit WorkersUpdated();
    }

    function onWorkerResponse(
        Controller storage _self,
        bytes32 _jobId,
        bytes32 _workerId,
        uint8 _responseType,
        bool _response)
    internal {
        checkResponse(_self, _jobId, _workerId, _response);
        // Transition to next state when all workers have responded
        if (isAllWorkerResponded) {
            if (_responseType == uint8(WorkerResponses.Assignment)) {
                //todo switch to new state
                resetAllResponses(_self, _jobId);
            } else if (_responseType == uint8(WorkerResponses.DataValidation)) {
                //todo switch to new state
                resetAllResponses(_self, _jobId);
            } else if (_responseType == uint8(WorkerResponses.Result)) {
                //todo switch to new state
            }
        }
    }

    ///@dev Checks is workera actually computing current job, then updates response's flag and timestamp
    function checkResponse(
        Controller _self,
        bytes32 _jobId,
        bytes32 _workerId,
        bool _response)
    private {
        workerIndex = getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        //todo implement penalties
        updateResponse(_self, _jobId, workerIndex, _response);
        trackOfflineWorkers();
    }

    //should be called for responseTimestamp refresh after actual progress change in workerNode
    //todo implement requirement of new progress > current progress in workerController
    function commitProgress(
        Controller storage _self,
        uint256 _jobId,
        uint256 _workerId,
        uint8 percent)
    internal {
        uint256 workerIndex = getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job
        _self.cognitiveJob[_jobId].responseTimestamps[workerIndex] = block.timestamp;
        emit CognitionProgressed(_percent);
    }

    /// @notice should be called with provided results
    function completeWork(
        Controller _self,
        bytes32 jobId,
        bytes32 _workerId,
        bytes _ipfsResults)
    internal {
        uint256 workerIndex = getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        _self.cognitiveJobs[_jobId].ipfsResults[workerIndex] = _ipfsResults;
        onWorkerResponse(_self, _jobId, _workerId, uint8(WorkerResponses.Result), true);
    }

    //todo move to manager
    function activeWorkersCount(Controller _self, bytes32 jobId)
    view
    internal
    returns(
        uint256
    ) {
        return _self.jobAddresses[jobId].activeWorkers.length;
    }

    //todo move to manager
    function didWorkerCompute(Controller storage _self, bytes32 jobId, uint256 no)
    view
    internal
    returns(
        bool
    ){
        return _self.jobAddresses[jobId].responseFlags[no];
    }

    //    function reportOfflineWorker(IWorkerNode reported) payable external; //todo should be implemented in workerController in upcoming version


    function getWorkerIndex(
        Controller storage _self,
        uint256 _jobId,
        uint256 _workerId)
    private
    returns (
        uint256
    ) {
        for (uint256 i = 0; i < _self.cognitiveJob[_jobId].activeWorkers.length; i++) {
            if (_self.cognitiveJob[_jobId].activeWorkers[i] == _workerId) {
                return i;
            }
        }
        return uint256(-1);
    }

    function isAllWorkersResponded(Controller storage _self, uint256 _jobId)
    private
    returns (
        bool responded
    ) {
        responded = true;
        for (uint256 i = 0; i < _self.cognitiveJobs[_jobId].responseFlags.length; i++) {
            if (_self.cognitiveJobs[_jobId].responseFlags[i] != true) {
                responded = false;
            }
        }
    }

    function updateResponse(
        Controller _self,
        bytes32 _jobId,
        uint256 _workerIndex,
        bool _response)
    private {
        _self.cognitiveJob[_jobId].responseFlags[_workerIndex] = _response;
        _self.cognitiveJob[_jobId].responseTimestamps[_workerIndex] = block.timestamp;
    }

    ///@dev Reset all response flags and update all timestamps
    function resetAllResponses(
        Controller _self,
        bytes32 _jobId)
    private {
        for (uint256 i = 0; i < _self.congitiveJob[_jobId].activeWorkers.length; i++) {
            _self.cognitiveJob[_jobId].responseFlags[i] = false;
            _self.cognitiveJob[_jobId].responseTimestamps[i] = block.timestamp;
        }
    }

    function _trackOfflineWorkers(
        Controller _self,
        bytes32 _jobId)
    private {
        //todo implement
    }

    function _getJobById(Controller _self, bytes32 _jobId)
    private
    returns(CognitiveJob) {
        return _self.cognitiveJobs[_self.jobAddresses[_jobId]];
    }

    /******************************************************************************************************************
    State machine implementation
    */

    modifier requireActiveStates(Controller _self, bytes32 _jobId) {
        require(
            _self.cognitiveJobs[jobAddresses[_jobId]].state == States.GatheringWorkers ||
            _self.cognitiveJobs[jobAddresses[_jobId]].state == States.DataValidation ||
            _self.cognitiveJobs[jobAddresses[_jobId]].state == States.Cognition
        );
        _;
    }

    modifier requireAllowedTransition(Controller _self, bytes32 _jobId, uint8 _newState) {
        // Checking if the state transition is allowed
        bool transitionAllowed = false;
        uint8[] storage allowedStates = _self.transitionTable[uint8(getJobById(_jobId).state)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _newState) {
                transitionAllowed = true;
            }
        }
        require(transitionAllowed == true);
        _;
    }

    //Fill table of possible state transitions
    function _initStateMachine(Controller _self) private {
        mapping(uint8 => uint8[]) transitions = _self.transitionTable;
        transitions[uint8(States.Uninitialized)] =
            [uint8(States.GatheringWorkers)];
        transitions[uint8(States.GatheringWorkers)] =
            [uint8(States.InsufficientWorkers), uint8(States.DataValidation)];
        transitions[uint8(States.DataValidation)] =
            [uint8(States.InvalidData), uint8(States.Cognition), uint8(States.InsufficientWorkers)];
        transitions[uint8(States.Cognition)] =
            [uint8(States.Completed), uint8(States.PartialResult)];
    }

    function _fireStateEvent(Controller _self, bytes32 _jobId) private {
        CognitiveJob job = getJobById(_jobId);
        if (job.state == uint8(States.InsufficientWorkers)) {
            emit WorkersNotFound();
            _cleanStorage(); //todo refactor with queue
        } else if (job.state == uint8(States.DataValidation)) {
            emit DataValidationStarted();
        } else if (job.state == uint8(States.InvalidData)) {
            emit DataValidationFailed();
            _cleanStorage(); //todo refactor
        } else if (job.state == uint8(States.Cognition)) {
            emit CognitionStarted();
        } else if (job.state == uint8(States.PartialResult)) {
            emit CognitionCompleted(true);
//            pandora.finishCognitiveJob();
        } else if (job.state == uint8(States.Completed)) {
            emit CognitionCompleted(false);
//            pandora.finishCognitiveJob();
        }
    }

    function _transitionToState(
        Controller _self,
        bytes32 _jobId,
        uint8 _newState)
    private
    requireAllowedTransition(_self, _jobId, _newState)
    {
        CognitiveJob job = getJobById(_jobId);
        uint8 oldState = job.state;
        job.state = _newState;
        emit JobStateChanged(_jobId, oldState, job.state);
        _fireStateEvent();
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
