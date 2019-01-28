const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();
const assertRevert = require('./helpers/assertRevert');

const Pandora = artifacts.require('Pandora');

contract('Pandora', ([owner1, owner2, owner3]) => {

    let pandora;    

    before('setup', async () => {
        pandora = await Pandora.deployed();        
    });

    describe('#whitelistWorkerOwner', () => {

        it('add an owner to the whitelist', async () => {
            await pandora.whitelistWorkerOwner(owner2);
            (await pandora.workerNodeOwners(owner2)).should.equal(true);
        });        
    });    
});
