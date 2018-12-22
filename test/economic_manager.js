const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();
const assertRevert = require('./helpers/assertRevert');

const EconomicManagerTests = artifacts.require('EconomicManagerTests');
const EconomicController = artifacts.require('EconomicController');
const TestOwnable = artifacts.require('TestOwnable');

contract('EconomicManager', ([owner1, owner2, owner3, owner4]) => {

    let tm;
    let controller;
    let nodeOwnable;
    const initialFunds2 = 200 * 1000000000000000000;
    const initialFunds3 = 200 * 1000000000000000000;

    beforeEach('setup', async () => {
        controller = await EconomicController.new({ from: owner1 });
        nodeOwnable = await TestOwnable.new({ from: owner4 });
        tm = await EconomicManagerTests.new(controller.address, { from: owner1 });
        await controller.transferOwnership(tm.address, { from: owner1 });
        await tm.initializeMintable(owner1, { from: owner1 });
        await tm.mint(owner1, 5000000 * 1000000000000000000, { from: owner1 });
        await tm.transfer(owner2, initialFunds2, { from: owner1 });        
        await tm.transfer(owner3, initialFunds3, { from: owner1 });
        await tm.transfer(owner4, initialFunds2, { from: owner1 });
    });

    describe('#hasEnoughFunds', () => {

        it('should fail to get worker node stake if stake was never added before', async () => {
            await assertRevert(tm.hasEnoughFunds(owner2, initialFunds2 * 2));
        });

        it('should return true if stake enough and otherwise', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            await tm.blockTokens(tokensToBlock, { from: owner2 });
            (await tm.hasEnoughFunds(owner2, tokensToBlock / 2)).should.equal(true);
            (await tm.hasEnoughFunds(owner2, tokensToBlock * 2)).should.equal(false);
        });
    });

    describe('#blockTokens', () => {
        
        it('should block tokens on address', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            const result = await tm.blockTokens(tokensToBlock, { from: owner2 });
            
            let events = result.logs.filter(l => (
                l.event === 'BlockedTokens' && result.tx === l.transactionHash
            ));
            (events.length).should.equal(1);
            (events[0].args.owner).should.equal(owner2);
            (events[0].args.value).should.be.bignumber.equal(tokensToBlock);
    
            (await tm.balanceOf(owner2)).should.be.bignumber.equal(initialFunds2-tokensToBlock);
            (await tm.getAvailableBalance(owner2)).should.be.bignumber.equal(tokensToBlock);
            (await tm.hasAvailableFunds(owner2)).should.equal(true);
        });
    
        it('should fail if sender has insufficient amount of tokens', async () => {
            await assertRevert(tm.blockTokens(250 * 1000000000000000000, { from: owner2 }));
        });
    });

    describe('#testBlockTokensFrom', () => {

        it('should block tokens on address', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            const result = await tm.testBlockTokensFrom(owner2, tokensToBlock, { from: owner1 });
            
            let events = result.logs.filter(l => (
                l.event === 'BlockedTokens' && result.tx === l.transactionHash
            ));
            (events.length).should.equal(1);
            (events[0].args.owner).should.equal(owner2);
            (events[0].args.value).should.be.bignumber.equal(tokensToBlock);
    
            (await tm.balanceOf(owner2)).should.be.bignumber.equal(initialFunds2-tokensToBlock);
            (await tm.getAvailableBalance(owner2)).should.be.bignumber.equal(tokensToBlock);
            (await tm.hasAvailableFunds(owner2)).should.equal(true);
        });
    });

    describe('#blockWorkerNodeStake', () => {
        
        it('should block tokens as worker node stake', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            const result = await tm.blockWorkerNodeStake(tokensToBlock, { from: owner2 });
            
            let events = result.logs.filter(l => (
                l.event === 'BlockedTokens' && result.tx === l.transactionHash
            ));
            (events.length).should.equal(1);
            (events[0].args.owner).should.equal(owner2);
            (events[0].args.value).should.be.bignumber.equal(tokensToBlock);
    
            (await tm.balanceOf(owner2)).should.be.bignumber.equal(initialFunds2-tokensToBlock);
            (await tm.getAvailableBalance(owner2)).should.be.bignumber.equal(tokensToBlock);
            (await tm.hasAvailableFunds(owner2)).should.equal(true);        
        });
    
        it('should fail if a value less then a minimum stake', async () => {
            await assertRevert(tm.blockWorkerNodeStake(90 * 1000000000000000000, { from: owner2 }));
        });
    });

    describe('#unblockTokensFrom', () => {
        
        it('should unblock tokens and transfer them to address', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await tm.blockTokens(tokensToBlock, { from: owner2 });
    
            const tokensToUnBlock = 50 * 1000000000000000000;
            const result = await tm.testUnblockTokensFrom(owner2, owner2, tokensToUnBlock, { from: owner2 });
            
            let events = result.logs.filter(l => (
                l.event === 'UnblockedTokens' && result.tx === l.transactionHash
            ));
            (events.length).should.equal(1);
            (events[0].args.from).should.equal(owner2);
            (events[0].args.to).should.equal(owner2);
            (events[0].args.value).should.be.bignumber.equal(tokensToUnBlock);
    
            (await tm.balanceOf(owner2)).should.be.bignumber.equal(initialFunds2-tokensToBlock+tokensToUnBlock);
            (await tm.getAvailableBalance(owner2)).should.be.bignumber.equal(tokensToBlock-tokensToUnBlock);
            (await tm.hasAvailableFunds(owner2)).should.equal(true);        
        });
    
        it('should fail if trying to unlock more tokens then blocked', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await tm.blockTokens(tokensToBlock, { from: owner2 });
    
            const tokensToUnBlock = 250 * 1000000000000000000;
            await assertRevert(tm.testUnblockTokensFrom(owner2, owner2, tokensToUnBlock));      
        });
    });

    describe('#hasAvailableFunds', () => {
        
        it('should return true if owner has blocked tokens and otherwise', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await tm.blockTokens(tokensToBlock, { from: owner2 });
            (await tm.hasAvailableFunds(owner2)).should.equal(true);
    
            await tm.testUnblockTokensFrom(owner2, owner2, tokensToBlock);
            (await tm.hasAvailableFunds(owner2)).should.equal(false);
        });
    
        it('should fail if owner not blocked its funds before', async () => {
            await assertRevert(tm.hasAvailableFunds(owner3));
        });
    });

    describe('#hasWorkerNodeAvailableFunds', () => {
        
        it('should return true if owner (worker node) has blocked tokens and otherwise', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await tm.blockTokens(tokensToBlock, { from: owner4 });
            (await tm.hasWorkerNodeAvailableFunds(nodeOwnable.address)).should.equal(true);
    
            const tokensToUnBlock = 150 * 1000000000000000000;
            await tm.testUnblockTokensFrom(owner4, owner4, tokensToUnBlock);
            (await tm.hasWorkerNodeAvailableFunds(nodeOwnable.address)).should.equal(false);            
        });
    });

    describe('#getAvailableBalance', () => {
        
        it('should return balance', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            await tm.blockTokens(tokensToBlock, { from: owner2 });
            (await tm.getAvailableBalance(owner2)).should.be.bignumber.equal(tokensToBlock);
        });
    });
    
});
