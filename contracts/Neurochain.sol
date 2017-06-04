pragma solidity ^0.4.8;

import './zeppelin/ownership/Multisig.sol';
import './Neurocoin.sol';
import './MasternodeContract.sol';
import './KernelContract.sol';
import './DatasetContract.sol';
import './HardwareContract.sol';
import './Neurocontract.sol';
import './NeurochainLib.sol';

contract Neurochain is Multisig, Neurocoin {
    uint constant masternodeLimit = 1000;

    mapping(address => MasternodeContract) masternodes;
    mapping(address => Neurocontract) public contracts;

    mapping(address => uint) lockedBalances;

    function registerMasternode(bytes pubKey) returns (MasternodeContract masternode) {
        MasternodeContract existingContract = masternodes[msg.sender];
        if (existingContract == address(0)) {
            throw;
        }
        if (balances[msg.sender] < masternodeLimit) {
            throw;
        }
        MasternodeContract newContract = new MasternodeContract(this, pubKey);
        masternodes[msg.sender] = newContract;
        balances[msg.sender] -= masternodeLimit;
        lockedBalances[msg.sender] = masternodeLimit;
        masternode = newContract;
    }

    function deployNeurocontract(
        KernelContract kernelContract,
        DatasetContract datasetContract,
        NeurochainLib.HardwareType hardwareType
    ) returns (Neurocontract workContract) {
        workContract = new Neurocontract(this, kernelContract, datasetContract, hardwareType);
        contracts[msg.sender] = workContract;
    }
}
