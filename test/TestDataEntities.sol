pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/entities/Kernel.sol";
import "../contracts/entities/Dataset.sol";

contract TestDataEntities {
    Kernel kernel;
    Dataset dataset;

    function beforeAll() {
        dataset = Dataset(DeployedAddresses.Dataset());
        kernel = Kernel(DeployedAddresses.Kernel());
    }

    function testDataDimEquivalence() {
        Assert.equal(kernel.dataDim(), dataset.dataDim(), "Kernel and dataset must have the same data dimension");
    }
}
