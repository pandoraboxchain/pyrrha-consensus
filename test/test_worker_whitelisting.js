const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();
const assertRevert = require('./helpers/assertRevert');

const Pandora = artifacts.require('Pandora');

contract('Pandora', ([owner1, owner2, owner3]) => {

    const initialFunds2 = 200 * 1000000000000000000;
    const initialFundsIn = 50 * 1000000000000000000;
    let pandora;    

    before('setup', async () => {
        pandora = await Pandora.deployed();
        await pandora.transfer(owner2, initialFunds2, { from: owner1 });
        await pandora.whitelistWorkerOwner(owner2);
    });

    describe('#whitelistWorkerOwner', () => {

        it('owner2 should be whitelisted and has a stake', async () => {
            (await pandora.workerNodeOwners(owner2)).should.equal(true);
            (await pandora.hasWorkerNodeStake(owner2)).should.equal(true);
        });

        it('should fail if worker without tokens', async () => {
            await assertRevert(pandora.whitelistWorkerOwner(owner3));
        });

        it('should fail if worker insufficient tokens', async () => {
            await pandora.transfer(owner3, initialFundsIn, { from: owner1 });
            await assertRevert(pandora.whitelistWorkerOwner(owner3));
        });
    });    
});
