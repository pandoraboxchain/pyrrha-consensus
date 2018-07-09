pragma solidity ^0.4.24;


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

        ///Table of all possible state transitions
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
//    function getCognitiveJobDetails(Controller _self, bytes32 _jobId)
//    public
//    returns (
//        bytes32, bytes32, uint256, bytes32, bytes32[], bytes[]
//    ) {
//        CognitiveJob job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
//        return (
//            job.kernel,
//            job.dataset,
//            job.complexity,
//            job.description,
//            job.activeWorkers,
//            job.ipfsResults
//        );
//    }

    //todo move to manager
//    function getCognitiveJobProgressInfo(bytes32 _jobId)
//    public
//    returns(
//        uint32[], bool[], uint8, uint8
//    ) {
//        CognitiveJob job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
//        return (
//            job.responseTimestamps,
//            job.responseFlags,
//            job.progress,
//            job.state
//        );
//    }

    function createCognitiveJob (
        Controller storage _self,
        bytes32 _kernel,
        bytes32 _dataset,
        bytes32[] _assignedWorkers,
        uint256 _complexity,
        bytes32 _description
    )
    internal {
        bytes32 id = keccak256(_self.cognitiveJobs.length + block.number);
        _self.cognitiveJobs.push(CognitiveJob({
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
        CognitiveJob storage job = _self.cognitiveJobs[_self.jobAddresses[id]];
        //init timestamps
        for (uint256 i = 0; i < job.responseTimestamps.length; i++) {
            job.responseTimestamps[i] = uint32(block.timestamp);
        }
        // add to addresses map
        _self.jobAddresses[id] = uint256(_self.cognitiveJobs.length);

        _transitionToState(_self, id, uint8(States.GatheringWorkers));
        emit WorkersUpdated(id);
    }

    /// @dev Could be called from manager with two types of response - Assignment and DataValidation
    function onWorkerResponse(
        Controller storage _self,
        bytes32 _jobId,
        bytes32 _workerId,
        uint8 _responseType,
        bool _response)
    internal {
        _checkResponse(_self, _jobId, _workerId, _response);
        // Transition to next state when all workers have responded
        if (isAllWorkersResponded(_self, _jobId)) {
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

    ///@dev Checks is worker actually computing current job, then updates response's flag and timestamp
    function _checkResponse(
        Controller storage _self,
        bytes32 _jobId,
        bytes32 _workerId,
        bool _response)
    private {
        uint256 workerIndex = getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        //todo implement penalties
        updateResponse(_self, _jobId, workerIndex, _response);
        _trackOfflineWorkers(_self, _jobId);
    }

    //should be called for responseTimestamp refresh after actual progress change in workerNode
    //todo implement requirement of new progress > current progress in workerController
    function commitProgress(
        Controller storage _self,
        bytes32 _jobId,
        bytes32 _workerId,
        uint8 _percent)
    internal {
        uint256 workerIndex = getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job
        _self.cognitiveJobs[_self.jobAddresses[_jobId]].responseTimestamps[workerIndex] = uint32(block.timestamp);
        emit CognitionProgressed(_jobId, _percent);
    }

    /// @notice should be called with provided results
    function completeWork(
        Controller storage _self,
        bytes32 _jobId,
        bytes32 _workerId,
        bytes _ipfsResults)
    internal {
        uint256 workerIndex = getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job

        _self.cognitiveJobs[_self.jobAddresses[_jobId]].ipfsResults[workerIndex] = _ipfsResults;
        onWorkerResponse(_self, _jobId, _workerId, uint8(WorkerResponses.Result), true);
    }

//    //todo move to manager
//    function activeWorkersCount(Controller _self, bytes32 jobId)
//    view
//    internal
//    returns(
//        uint256
//    ) {
//        return _self.jobAddresses[jobId].activeWorkers.length;
//    }
//
//    //todo move to manager
//    function didWorkerCompute(Controller storage _self, bytes32 jobId, uint256 no)
//    view
//    internal
//    returns(
//        bool
//    ){
//        return _self.jobAddresses[jobId].responseFlags[no];
//    }

    //    function reportOfflineWorker(IWorkerNode reported) payable external;
    //todo should be implemented in workerController in upcoming version

    function getWorkerIndex(
        Controller storage _self,
        bytes32 _jobId,
        bytes32 _workerId)
    private
    view
    returns (
        uint256
    ) {
        CognitiveJob storage job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        for (uint256 i = 0; i < job.activeWorkers.length; i++) {
            if (job.activeWorkers[i] == _workerId) {
                return i;
            }
        }
        return uint256(-1);
    }

    function isAllWorkersResponded(
        Controller storage _self,
        bytes32 _jobId)
    private
    view
    returns (
        bool responded
    ) {
        responded = true;
        CognitiveJob storage job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        for (uint256 i = 0; i < job.responseFlags.length; i++) {
            if (job.responseFlags[i] != true) {
                responded = false;
            }
        }
    }

    function updateResponse(
        Controller storage _self,
        bytes32 _jobId,
        uint256 _workerIndex,
        bool _response)
    private {
        _self.cognitiveJobs[_self.jobAddresses[_jobId]].responseFlags[_workerIndex] = _response;
        _self.cognitiveJobs[_self.jobAddresses[_jobId]].responseTimestamps[_workerIndex] = uint32(block.timestamp);
    }

    ///@dev Reset all response flags and update all timestamps
    function resetAllResponses(
        Controller storage _self,
        bytes32 _jobId)
    private {
        CognitiveJob storage job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        for (uint256 i = 0; i < job.activeWorkers.length; i++) {
            job.responseFlags[i] = false;
            job.responseTimestamps[i] = uint32(block.timestamp);
        }
    }

    function _trackOfflineWorkers(
        Controller storage _self,
        bytes32 _jobId)
    private {
        //todo implement
    }

    /******************************************************************************************************************
    State machine implementation
    */

    modifier requireActiveStates(
        Controller storage _self,
        bytes32 _jobId
    ) {
        CognitiveJob storage job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        require(
            job.state == uint8(States.GatheringWorkers) ||
            job.state == uint8(States.DataValidation) ||
            job.state == uint8(States.Cognition)
        );
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
            _self.transitionTable[uint8(_self.cognitiveJobs[_self.jobAddresses[_jobId]].state)];
        for (uint no = 0; no < allowedStates.length; no++) {
            if (allowedStates[no] == _newState) {
                transitionAllowed = true;
            }
        }
        require(transitionAllowed == true);
        _;
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
    }

    function _fireStateEvent(
        Controller storage _self,
        bytes32 _jobId)
    private {
        uint8 state = _self.cognitiveJobs[_self.jobAddresses[_jobId]].state;
        if (state == uint8(States.InsufficientWorkers)) {
            emit WorkersNotFound(_jobId);
            //_cleanStorage(); //todo refactor with queue
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
        }
    }

    function _transitionToState(
        Controller storage _self,
        bytes32 _jobId,
        uint8 _newState)
    private
    requireAllowedTransition(_self, _jobId, _newState)
    {
        CognitiveJob storage job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        uint8 oldState = job.state;
        job.state = _newState;
        emit JobStateChanged(_jobId, oldState, job.state);
        _fireStateEvent(_self, _jobId);
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
