pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../../jobs/CognitiveJob.sol';
import '../../entities/IDataEntity.sol';
import '../../entities/IDataset.sol';
import '../../entities/IKernel.sol';
import '../../nodes/IWorkerNode.sol';
import '../IPandora.sol';

contract CognitiveJobFactory is Ownable {
    function CognitiveJobFactory() public { }

    function create(
        IKernel _kernel,
        IDataset _dataset,
        IWorkerNode[] _workersPool
    )
    onlyOwner
    external
    returns (CognitiveJob) {
        return new CognitiveJob(IPandora(owner), _kernel, _dataset, _workersPool);
    }
}
