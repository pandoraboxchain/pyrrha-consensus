/**
 * Created by orlovsky on 04-06-2017.
 */

// Include web3 library so we can query accounts.
const Web3 = require('web3')
// Instantiate new web3 object pointing toward an Ethereum node.
let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))
// Include AuthorDonation contract
let Neurochain = artifacts.require("./Neurochain.sol")
let DatasetContract = artifacts.require("./DatasetContract.sol")
let KernelContract = artifacts.require("./KernelContract.sol")
let HardwareContract = artifacts.require("./HardwareContract.sol")
let MasternodeContract = artifacts.require("./MasternodeContract.sol")
let Neurocontract = artifacts.require("./Neurocontract.sol")

contract('Neurochain', function (accounts) {

    it("Neurochain base contract should be deployed", function (done) {
        Neurochain.deployed().then(function (neurochain) {
            done()
        })
    })

    /*
    it("Should be able to create new kernel contract", function (done) {
        KernelContract.new(
            'QmPhtLgduZaCJFQ4SReNMDnHo7Lb6YyVQU1wCiJdvw6CJa',
            'QmQuHbEaQem2KGHwgpcZs7dHMeu8sm4npjbDA8NRXLPfPo',
            1
        ).then(function (kernelContract) {
            done()
            console.log(kernelContract.address)
        })
    })
    */

    /*
    it("Neurochain initial token balance must be 1000 coins", function (done) {
        Neurochain.deployed().then(function (neurochain) {
            return neurochain.getLockedBalances().call(accounts[0])
        }).then(function (balance) {
            assert.equal(balance.valueOf(), 1000, "1000 wasn't in the first account")
        })
    })
    */
})
