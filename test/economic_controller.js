const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();
const assertRevert = require('./helpers/assertRevert');
const eventFired = require('./helpers/eventFired');

const Pan = artifacts.require('Pan');
const EconomicControllerTests = artifacts.require('EconomicControllerTests');
const EconomicController = artifacts.require('EconomicController');
const TestOwnable = artifacts.require('TestOwnable');

contract('EconomicManager', ([owner1, owner2, owner3, owner4]) => {

    let tm;
    let pan;
    let controller;
    let nodeOwnable;
    const initialFunds2 = 200 * 1000000000000000000;
    const initialFunds3 = 200 * 1000000000000000000;

    beforeEach('setup', async () => {
        pan = await Pan.new({ from: owner1 });
        await pan.initializeMintable(owner1, { from: owner1 });
        await pan.mint(owner1, 5000000 * 1000000000000000000, { from: owner1 });

        controller = await EconomicController.new(pan.address, { from: owner1 });
        nodeOwnable = await TestOwnable.new({ from: owner4 });
        
        tm = await EconomicControllerTests.new(controller.address, { from: owner1 });
        await controller.transferOwnership(tm.address, { from: owner1 });

        await controller.initialize(tm.address);
        
        await pan.transfer(owner2, initialFunds2, { from: owner1 });        
        await pan.transfer(owner3, initialFunds3, { from: owner1 });
        await pan.transfer(owner4, initialFunds2, { from: owner1 });        
    });

    describe('#hasEnoughFunds', () => {

        it('should fail to get worker node stake if stake was never added before', async () => {
            await assertRevert(controller.hasEnoughFunds(owner2, initialFunds2 * 2));
        });

        it('should return true if stake enough and otherwise', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            await controller.blockTokens(tokensToBlock, { from: owner2 });
            (await controller.hasEnoughFunds(owner2, tokensToBlock / 2)).should.equal(true);
            (await controller.hasEnoughFunds(owner2, tokensToBlock * 2)).should.equal(false);
        });
    });

    describe('#blockTokens', () => {
        
        it('should block tokens on address', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            let result;

            await assertRevert(controller.blockTokens(tokensToBlock, { from: owner2 }), "Not approved");

            await pan.approve(controller.address, tokensToBlock, {from: owner2});

            await assertRevert(controller.blockTokens(tokensToBlock * 1.1, { from: owner2 }), "Not approved amount");

            result = await controller.blockTokens(tokensToBlock, { from: owner2 });
            
            let events = result.logs.filter(l => (
                l.event === 'BlockedTokens' && result.tx === l.transactionHash
            ));
            (events.length).should.equal(1);
            (events[0].args.owner).should.equal(owner2);
            (events[0].args.value).should.be.bignumber.equal(tokensToBlock);
    
            (await pan.balanceOf(owner2)).should.be.bignumber.equal(initialFunds2-tokensToBlock);
            (await controller.balanceOf(owner2)).should.be.bignumber.equal(tokensToBlock);
            (await controller.hasAvailableFunds(owner2)).should.equal(true);
        });
    
        it('should fail if sender has insufficient amount of tokens', async () => {
            const tokensToBlock = 250 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            await assertRevert(controller.blockTokens(tokensToBlock, { from: owner2 }));
        });
    });

    describe('#blockWorkerNodeStake', () => {
        
        it('should block tokens in amount of worker node stake', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            const result = await controller.blockWorkerNodeStake({ from: owner2 });
            
            let events = result.logs.filter(l => (
                l.event === 'BlockedTokens' && result.tx === l.transactionHash
            ));
            (events.length).should.equal(1);
            (events[0].args.owner).should.equal(owner2);
            (events[0].args.value).should.be.bignumber.equal(tokensToBlock);
    
            (await pan.balanceOf(owner2)).should.be.bignumber.equal(initialFunds2-tokensToBlock);
            (await controller.balanceOf(owner2)).should.be.bignumber.equal(tokensToBlock);
            (await controller.hasAvailableFunds(owner2)).should.equal(true);        
        });
    
        it('should fail if a approuved amount less then a minimum stake', async () => {
            const tokensToBlock = 90 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            await assertRevert(controller.blockWorkerNodeStake({ from: owner2 }));
        });
    });

    describe('#unblockTokensFrom', () => {
        
        it('should unblock tokens and transfer them to address', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            await controller.blockTokens(tokensToBlock, { from: owner2 });

            const tokensToUnBlock = 50 * 1000000000000000000;
            await tm.testUnblockTokensFrom(owner2, owner2, tokensToUnBlock, { from: owner2 });

            const result = await eventFired(controller, 'UnblockedTokens');

            (result.length).should.equal(1);
            (result[0].args.from).should.equal(owner2);
            (result[0].args.to).should.equal(owner2);
            (result[0].args.value).should.be.bignumber.equal(tokensToUnBlock);
    
            (await pan.balanceOf(owner2)).should.be.bignumber.equal(initialFunds2-tokensToBlock+tokensToUnBlock);
            (await controller.balanceOf(owner2)).should.be.bignumber.equal(tokensToBlock-tokensToUnBlock);
            (await controller.hasAvailableFunds(owner2)).should.equal(true);        
        });
    
        it('should fail if trying to unblock more tokens then blocked', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            await controller.blockTokens(tokensToBlock, { from: owner2 });
    
            await assertRevert(tm.testUnblockTokensFrom(owner2, owner2, tokensToBlock * 2));      
        });
    });

    describe('#hasAvailableFunds', () => {
        
        it('should return true if owner has blocked tokens and otherwise', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            await controller.blockTokens(tokensToBlock, { from: owner2 });
            (await controller.hasAvailableFunds(owner2)).should.equal(true);
    
            await tm.testUnblockTokensFrom(owner2, owner2, tokensToBlock);
            (await controller.hasAvailableFunds(owner2)).should.equal(false);
        });
    
        it('should fail if owner not blocked its funds before', async () => {
            await assertRevert(controller.hasAvailableFunds(owner3));
        });
    });

    describe('#positiveWorkerNodeStake', () => {
        
        it('should return true if owner (worker node) has blocked tokens and otherwise', async () => {
            const tokensToBlock = 150 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner4});
            await controller.blockTokens(tokensToBlock, { from: owner4 });
            (await controller.positiveWorkerNodeStake(nodeOwnable.address)).should.equal(true);
    
            const tokensToUnBlock = 150 * 1000000000000000000;
            await tm.testUnblockTokensFrom(owner4, owner4, tokensToUnBlock);
            (await controller.positiveWorkerNodeStake(nodeOwnable.address)).should.equal(false);            
        });
    });

    describe('#balanceOf', () => {
        
        it('should return balance of blocked funds', async () => {
            const tokensToBlock = 100 * 1000000000000000000;
            await pan.approve(controller.address, tokensToBlock, {from: owner2});
            await controller.blockTokens(tokensToBlock, { from: owner2 });
            (await controller.balanceOf(owner2)).should.be.bignumber.equal(tokensToBlock);
        });
    });
    
});
