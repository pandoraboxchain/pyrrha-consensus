pragma solidity ^0.4.8;

/*

 */

import './zeppelin/lifecycle/Destructible.sol';
import './interfaces/MasternodeManaged.sol';
import './KernelContract.sol';
import './DatasetContract.sol';
import './HardwareContract.sol';

contract Neurocontract is Destructible, MasternodeManaged {
    KernelContract kernelContract;
    DatasetContract datasetContract;
    HardwareContract.Type compatibility;
    address rootNeurochain;

    uint completedSamplesCount = 0;

    function Neurocontract(
        address _rootNeurochain,
        KernelContract _kernelContract,
        DatasetContract _datasetContract,
        HardwareContract.Type _hardwareType
    ) {
        rootNeurochain = _rootNeurochain;
        kernelContract = _kernelContract;
        datasetContract = _datasetContract;
        compatibility = _hardwareType;
        //this.prepayWork();
    }

    function prepayWork() payable onlyOwner {
        // TODO: Check that payment is sufficient for the task completion
        startWork();
    }

    function startWork() private onlyOwner {

    }

    function commitWork(uint processedAmount) onlyMasternodes {
        completedSamplesCount += processedAmount;
    }
}
