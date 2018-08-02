const Web3 = require('web3');
// const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
const web3 = new Web3(new Web3.providers.HttpProvider('https://rinkeby.infura.io/'));

const pandora = require('./build/contracts/Pandora');
const controller = require('./build/contracts/CognitiveJobController');

const managerInstance = new web3.eth.Contract(pandora.abi, '0x853be7e8af1686893648cf34117c618f9eae56ea');
// console.log(managerInstance.options.address);

managerInstance.methods.jobController().call()
    .then(controllerAddress => {
        const jctrl = new web3.eth.Contract(controller.abi, controllerAddress);
        console.log(jctrl.options.address);

        jctrl.methods.getCognitiveJobDetails(web3.utils.toHex(web3.utils.sha3("1"))).call()
            .then(result => {
                console.log(result)
            });
    });