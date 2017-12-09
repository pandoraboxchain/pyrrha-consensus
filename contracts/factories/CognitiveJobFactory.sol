pragma solidity ^0.4.15;

import '../CognitiveJob.sol';
import '../Kernel.sol';
import '../Dataset.sol';
import '../Pandora.sol';
import '../WorkerNode.sol';

contract CognitiveJobFactory {
    function CognitiveJobFactory() { }

    function create(
        Pandora _pandora,
        Kernel _kernel,
        Dataset _dataset,
        WorkerNode[] _workersPool
    ) returns (CognitiveJob) {
        return new CognitiveJob(_pandora, _kernel, _dataset, _workersPool);
    }
}
