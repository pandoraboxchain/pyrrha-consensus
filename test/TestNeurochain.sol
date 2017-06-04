pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Neurochain.sol";
import "../contracts/HardwareContract.sol";

contract TestNeurochain {
    function getNeurochain() returns (Neurochain neurochain) {
        neurochain = Neurochain(DeployedAddresses.Neurochain());
    }

    function createKernelContract() returns (KernelContract kernelContract) {
        kernelContract = new KernelContract(
            'QmPhtLgduZaCJFQ4SReNMDnHo7Lb6YyVQU1wCiJdvw6CJa',
            'QmQuHbEaQem2KGHwgpcZs7dHMeu8sm4npjbDA8NRXLPfPo',
            1
        );
    }

    function createDatasetContract() returns (DatasetContract datasetContract) {
        datasetContract = new DatasetContract(
            'QmNxi5m9oZekHcfddayPwKNmsFfBGAP39CZXSnjnC2yF6B',
            7,
            1
        );
    }

    function createHardwareContract() returns (HardwareContract hardwareContract) {
        hardwareContract = new HardwareContract(
            'localhost:50051',
            HardwareContract.Type.GPU,
            1
        );
    }

    function testDeployedNeurochain() {
        Neurochain neurochain = getNeurochain();
        Assert.notEqual(neurochain, address(0), "Neurochain contract should be initialized");
    }

    function testCreateKernel() {
        KernelContract kernel = createKernelContract();
        Assert.notEqual(kernel, address(0), "Kernel contract should be initialized");
    }

    function testCreateDataset() {
        DatasetContract dataset = createDatasetContract();
        Assert.notEqual(dataset, address(0), "Dataset contract should be initialized");
    }

    function testCreateWorker() {
        HardwareContract worker = createHardwareContract();
        Assert.notEqual(worker, address(0), "Hardware contract should be initialized");
    }

    /*
    function testCreateNeurocontract() {
        KernelContract kernel = createKernelContract();
        DatasetContract dataset = createDatasetContract();
        Neurochain neurochain = getNeurochain();

        Neurocontract neurocontract = new Neurocontract(neurochain, kernel, dataset, HardwareContract.Type.GPU);
        Assert.notEqual(neurocontract, address(0), "Neurocontract should be initialized");
    }
    */

    function testCreateNeurocontractFromNeurochain() {
        KernelContract kernel = createKernelContract();
        DatasetContract dataset = createDatasetContract();
        HardwareContract worker = createHardwareContract();
        Neurochain neurochain = getNeurochain();

        Neurocontract neurocontract = neurochain.deployNeurocontract(kernel, dataset, HardwareContract.Type.GPU);

        Assert.notEqual(neurocontract, address(0), "Neurocontract should be initialized from within Neurochain");
    }
}
