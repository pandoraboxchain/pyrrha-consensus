pragma solidity ^0.4.23;

import "openzeppelin-solidity\contracts\ownership\Ownable.sol";
import "openzeppelin-solidity\contracts\math\SafeMath.sol";

import "./ICognitiveJobController.sol";
import "..\..\entities\IKernel.sol";
import "..\..\entities\IDataset.sol";
import "..\..\nodes\IWorkerNode.sol";
import "..\..\jobs\CognitiveJob.sol";


// Contract implement main cognitive job functionality
library CognitiveJobController {

    /*******************************************************************************************************************
     * ## Storage
     */

    enum DataValidationResponse {
        Accept, Decline, Invalid
    }

    uint8 internal constant WORKER_TIMEOUT = 30 minutes;

    uint8 public constant Destroyed = 0xFF;
    // Reserved system state not participating in transition table. Since contract creation all variables are
    // initialized to zero and contract state will be zero until it will be initialized with some definite state
    uint8 public constant Uninitialized = 0;
    uint8 public constant GatheringWorkers = 1;
    uint8 public constant InsufficientWorkers = 2;
    uint8 public constant DataValidation = 3;
    uint8 public constant InvalidData = 4;
    uint8 public constant Cognition = 5;
    uint8 public constant PartialResult = 6;
    uint8 public constant Completed = 7;

    /// ### Public variables

    struct Controller {
        /// @dev Indexes (+1) of active (=running) cognitive jobs in `activeJobs` mapped from their creators
        /// (owners of the corresponding cognitive job contracts). Zero values corresponds to no active job,
        /// one – to the one with index 0 and so forth.
        mapping(bytes32 => uint256) jobAddresses;

        /// @dev List of all active cognitive jobs
        CognitiveJob[] cognitiveJobs;
    }

    struct CognitiveJob {
        bytes32 id;
        bytes32 kernel;
        bytes32 dataset;
        uint8 progress;
        uint8 batches;
        uint256 complexity; //todo find better name
        bytes32 description;
        bytes32[] activeWorkers;
        uint32[] responseTimestamps; // time of each worker response
        bool[] responseFlags;
        bytes[] ipfsResults;
    }

    using SafeMath for uint;

    /*******************************************************************************************************************
     * ## Functions
     */

    /// ### Public and external

    function getCongitiveJobDetails(bytes32 id)
    public
    returns (

    ){

    }

    function getCognitiveJobInfo(bytes32 id)
    public
    returns(

    ){

    }

    function createCognitiveJob (
        Controller _self,
        bytes32 _kernel,
        bytes32 _dataset,
        bytes32[] _assignedWorkers,
        uint256 _complexity,
        bytes32 _description,
        uint8 _batches
    )
    external {
        CognitiveJob job = CognitiveJob({
            id: keccak256(_self.cognitiveJobs.length + block.number),
            kernel: _kernel,
            dataset: _dateset,
            progress: 0,
            batches: _batches,
            complexity: _complexity,
            description: _description,
            activeWorkers: _assignedWorkers,
            responseTimestamps: new uint[](_batches),
            responseFlags: new bool[](_batches),
            ipfsResults: new bytes[](_batches)
        });

        //add to register newly created job
        _self.cognitiveJobs.push(job);
        _self.jobAddresses[job.id] = job;

        //todo switch to state
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
            //todo switch to state
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
            //todo swich to new state
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

    //should be called for refreshing responceTimestamp after actual progress change in workerNode
    //todo implement requirement of new progeress > current progress in workerController
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

    function resetAllResponses(
        Controller _self,
        bytes32 _jobId)
    private {
        for (uint256 i = 0; i < _self.congitiveJob[_jobId].activeWorkers.length; i++) {
            _self.cognitiveJob[_jobId].responseFlags[i] = _response;
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
