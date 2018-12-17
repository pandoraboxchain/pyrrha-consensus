const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();
const assertRevert = require('./helpers/assertRevert');
const TokensManager = artifacts.require('TokensManager');

contract('TokensManager', ([owner1, owner2, owner3]) => {

    let tm;

    beforeEach('setup', async () => {
        tm = await TokensManager.new({ from: owner1 });
        await tm.initializeMintable(owner1);
        await tm.mint(owner1, 5000000 * 1000000000000000000, { from: owner1 });
        await tm.transfer(owner2, 150 * 1000000000000000000, { from: owner1 });        
    });

    it('#isWorkerNodeHasStake should fail to get worker node stake if stake was never added begore', async () => {
        await assertRevert(tm.isWorkerNodeHasStake(owner2));
    });

    it('#addWorkerNodeStake should add stake to address', async () => {
        const tokensToAdd = 100 * 1000000000000000000;
        const result = await tm.addWorkerNodeStake(tokensToAdd, { from: owner2 });
        
        let events = result.logs.filter(l => (
            l.event === 'StakeAdded' && result.tx === l.transactionHash
        ));
        (events.length).should.equal(1);
        (events[0].args.owner).should.equal(owner2);
        (events[0].args.value).should.be.bignumber.equal(tokensToAdd);

        events = result.logs.filter(l => (
            l.event === 'StakeBlocked' && result.tx === l.transactionHash
        ));
        (events.length).should.equal(1);
        (events[0].args.owner).should.equal(owner2);
        (events[0].args.value).should.be.bignumber.equal(tokensToAdd);

        (await tm.isWorkerNodeHasStake(owner2)).should.equal(true);
    });

    it('#addWorkerNodeStake should add stake to address if amount of tokens more when minimumTokensToStake (100 PAN)', async () => {
        const tokensToAdd = 110 * 1000000000000000000;
        const tokensToBlock = 100 * 1000000000000000000;
        const result = await tm.addWorkerNodeStake(tokensToAdd, { from: owner2 });

        let events = result.logs.filter(l => (
            l.event === 'StakeBlocked' && result.tx === l.transactionHash
        ));
        (events.length).should.equal(1);
        (events[0].args.owner).should.equal(owner2);
        (events[0].args.value).should.be.bignumber.equal(tokensToBlock);

        (await tm.isWorkerNodeHasStake(owner2)).should.equal(true);
    });

    it('#addWorkerNodeStake should fail if triyng to add more tokens when awailable', async () => {
        await assertRevert(tm.addWorkerNodeStake(151 * 1000000000000000000, { from: owner2 }));
    });

    it('#addWorkerNodeStake should fail if triyng to add less tokens when minimumTokensToStake (100 PAN)', async () => {
        await assertRevert(tm.addWorkerNodeStake(99 * 1000000000000000000, { from: owner2 }));
    });

    it('#addWorkerNodeStake should fail if triyng to add less tokens when 1', async () => {
        await assertRevert(tm.addWorkerNodeStake(0.5, { from: owner2 }));
    });
});
