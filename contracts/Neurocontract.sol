pragma solidity ^0.4.8;

/*

 */

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'interfaces/MasternodeManaged.sol';
import 'KernelContract.sol';
import 'DatasetContract.sol';
import 'HardwareContract.sol';
import 'Neurochain.sol';

contract Neurocontract is Destructible, MasternodeManaged {
    KernelContract kernelContract;
    DatasetContract datasetContract;
    HardwareType compatibility;
    Neurochain rootNeurochain;

    uint completedSamplesCount = 0;

    function Neurocontract(Neurochain _rootNeurochain, KernelContract _kernelContract, DatasetContract _datasetContract, HardwareType _hardwareType) {
        rootNeurochain = _rootNeurochain;
        kernelContract = _kernelContract;
        datasetContract = _datasetContract;
        hardwareType = _hardwareType;
        this.prepayWork();
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
