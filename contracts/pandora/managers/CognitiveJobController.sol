pragma solidity ^0.4.23;

import "openzeppelin-solidity\contracts\math\SafeMath.sol";

import "..\..\entities\IKernel.sol";
import "..\..\entities\IDataset.sol";
import "..\..\nodes\IWorkerNode.sol";


// Contract implement main cognitive job functionality
library CognitiveJobController {

    /*******************************************************************************************************************
     * ## Storage
     */

    struct Controller {
        /// @dev Indexes (+1) of active (=running) cognitive jobs in `activeJobs` mapped from their creators
        /// (owners of the corresponding cognitive job contracts). Zero values corresponds to no active job,
        /// one – to the one with index 0 and so forth.
        mapping(bytes32 => uint256) jobAddresses;

        /// @dev List of all active cognitive jobs
        CognitiveJob[] cognitiveJobs;

        //todo implement states and table in state machine
//        uint8 WORKER_TIMEOUT = 30 minutes;
//
//        uint8 Destroyed = 0xFF;
//        // Reserved system state not participating in transition table. Since contract creation all variables are
//        // initialized to zero and contract state will be zero until it will be initialized with some definite state
//        uint8  Uninitialized = 0;
//        uint8 GatheringWorkers = 1;
//        uint8 InsufficientWorkers = 2;
//        uint8 DataValidation = 3;
//        uint8 InvalidData = 4;
//        uint8 Cognition = 5;
//        uint8 PartialResult = 6;
//        uint8 Completed = 7;
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
    }

    using SafeMath for uint;

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

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

    function getCognitiveJobProgressInfo(bytes32 _jobId)
    public
    returns(
        uint32[], bool[], uint8
    ) {
        CognitiveJob job = _self.cognitiveJobs[_self.jobAddresses[_jobId]];
        return (
            job.responseTimestamps,
            job.responseFlags,
            job.progress
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
    external {
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

    function activeWorkersCount(Controller _self, bytes32 jobId)
    view
    external
    returns(
        uint256
    ) {
        return _self.jobAddresses[jobId].activeWorkers.length;
    }

    function didWorkerCompute(Controller storage _self, bytes32 jobId, uint256 no)
    view
    external
    returns(
        bool
    ){
        return _self.jobAddresses[jobId].responseFlags[no];
    }

//    function reportOfflineWorker(IWorkerNode reported) payable external; //todo should be implemented in workerController in upcoming version

    function acceptanceResponse(
        Controller storage _self,
        bytes32 _jobId,
        bytes32 _workerId,
        bool _response)
    external {
        checkResponse(_self, _jobId, _workerId, _response);
        // Transition to next state when all workers have responded
        if (isAllWorkerResponded) {
            resetAllResponses(_self, _jobId);
            //todo switch to new state
        }
    }

    function dataValidationResponse(
        Controller _self,
        bytes32 _jobId,
        bytes32 _workerId,
        bool _response)
    external {
        checkResponse(_self, _jobId, _workerId, _response);
        // Transition to next state when all workers have responded
        if (isAllWorkersResponded(_self, _jobId)) {
            resetAllResponses(_self, _jobId);
            //todo switch to new state
        }
    }

    function checkResponse(
        Controller _self,
        bytes32 _jobId,
        bytes32 _workerId,
        bool _response)
    private {
        uint256 workerIndex = getWorkerIndex(_self, _jobId, _workerId);
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
    external {
        uint256 workerIndex = getWorkerIndex(_self, _jobId, _workerId);
        require(workerIndex != uint256(-1)); //worker is computing current job
        _self.cognitiveJob[_jobId].responseTimestamps[workerIndex] = block.timestamp;
        emit CognitionProgressed(_percent);
    }

    function completeWork(bytes ipfs) external returns(bool isFinalized);

    function unlockFinalizedWorker() external;


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

    function trackOfflineWorkers(
        Controller _self,
        bytes32 _jobId)
    private {
        //todo implement
    }

    /******************************************************************************************************************
     * ## Events
     */

    event WorkersUpdated();
    event WorkersNotFound();
    event DataValidationStarted();
    event DataValidationFailed();
    event CognitionStarted();
    event CognitionProgressed(uint8 precent);
    event CognitionCompleted(bool partialResult);

    /** TODO should be implemented: 1) TrackOfflineWorker after each worker's response

    */
}
