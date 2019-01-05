const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();
const assertRevert = require('./helpers/assertRevert');
const Pan = artifacts.require('Pan');

contract('Pan', ([owner1, owner2, owner3]) => {
    
    const totalSupply = 5000000;
    let pan;

    beforeEach(async () => {
        pan = await Pan.new({ from: owner1 });
        await pan.initializeMintable(owner1, { from: owner1 });
        await pan.mint(owner1, totalSupply, { from: owner1 });        
    });

    describe('ERC20 getters', () => {

        it('standart constants', async () => {
            const name = await pan.name();
            const symbol = await pan.symbol();
            const decimals = await pan.decimals();
            (name).should.equal('Pandora AI Network Token');
            (symbol).should.equal('PAN');
            (decimals).should.be.bignumber.equal(18);
        });

        it('#totalSupply', async () => {
            const ts = await pan.totalSupply();
            (ts).should.be.bignumber.equal(totalSupply);
        });

        it('#balanceOf', async () => {
            const balance = await pan.balanceOf(owner1);
            (balance).should.be.bignumber.equal(totalSupply);
        });
    });

    describe('Allowance', () => {

        it('#approve should add allowance to the address', async () => {
            const allowedAmount = 1000000;
            const approveResult = await pan.approve(owner2, allowedAmount, {
                from: owner1
            });
            let event = approveResult.logs.filter(l => (
                l.event === 'Approval' && approveResult.tx === l.transactionHash
            ));            
            (event.length).should.equal(1);
            (event[0].args.owner).should.equal(owner1);
            (event[0].args.spender).should.equal(owner2);
            (event[0].args.value).should.be.bignumber.equal(allowedAmount);

            const allowance = await pan.allowance(owner1, owner2);
            (allowance).should.be.bignumber.equal(allowedAmount);
        });

        it('#increaseAllowance should inrease allowance to the address', async () => {
            await pan.approve(owner2, 1000000, {
                from: owner1
            });
            const increaseResult = await pan.increaseAllowance(owner2, 500000, {
                from: owner1
            });
            let event = increaseResult.logs.filter(l => (
                l.event === 'Approval' && increaseResult.tx === l.transactionHash
            ));
            (event.length).should.equal(1);
            (event[0].args.owner).should.equal(owner1);
            (event[0].args.spender).should.equal(owner2);
            (event[0].args.value).should.be.bignumber.equal(1500000);
        });

        it('#increaseAllowance should fail if spender address is invalid', async () => {
            await assertRevert(pan.increaseAllowance(0x0, 500000, {
                from: owner1
            }));
        });

        it('#decreaseAllowance', async () => {
            await pan.approve(owner2, 1000000, {
                from: owner1
            });
            const decreaseResult = await pan.decreaseAllowance(owner2, 500000, {
                from: owner1
            });
            let event = decreaseResult.logs.filter(l => (
                l.event === 'Approval' && decreaseResult.tx === l.transactionHash
            ));
            (event.length).should.equal(1);
            (event[0].args.owner).should.equal(owner1);
            (event[0].args.spender).should.equal(owner2);
            (event[0].args.value).should.be.bignumber.equal(500000);
        });

        it('#decreaseAllowance should fail if spender address is invalid', async () => {
            await assertRevert(pan.decreaseAllowance(0x0, 500000, {
                from: owner1
            }));
        });
    });

    describe('Minting', () => {

        it('#mint should mint specific amount of tokens', async () => {
            const amountToMint = 500000;
            const mintResult = await pan.mint(owner1, amountToMint, {
                from: owner1
            });
            let event = mintResult.logs.filter(l => (
                l.event === 'Transfer' && mintResult.tx === l.transactionHash
            ));
            (event.length).should.equal(1);
            (event[0].args.from).should.equal('0x0000000000000000000000000000000000000000');
            (event[0].args.to).should.equal(owner1);
            (event[0].args.value).should.be.bignumber.equal(amountToMint);

            const ts = await pan.totalSupply();
            (ts).should.be.bignumber.equal(totalSupply + amountToMint);
        });

        it('#mint should fail if called by not a minter role address', async () => {
            await assertRevert(pan.mint(owner1, 500000, {
                from: owner2
            }));
        });
    });

    describe('Transferring', () => {

        it('#transfer should transfer tokens to address', async () => {
            const amountToTransfer = 1000;
            const transferResult = await pan.transfer(owner2, amountToTransfer, {
                from: owner1
            });
            let event = transferResult.logs.filter(l => (
                l.event === 'Transfer' && transferResult.tx === l.transactionHash
            ));
            (event.length).should.equal(1);
            (event[0].args.from).should.equal(owner1);
            (event[0].args.to).should.equal(owner2);
            (event[0].args.value).should.be.bignumber.equal(amountToTransfer);

            const balance2 = await pan.balanceOf(owner2);
            (balance2).should.be.bignumber.equal(amountToTransfer);
        });

        it('#transfer should fail if sender has insufficient balance', async () => {
            await assertRevert(pan.transfer(0x0, 1000, {
                from: owner1
            }));
        });

        it('#transfer should fail if sender has insufficient balance', async () => {
            await assertRevert(pan.transfer(owner2, 10000000, {
                from: owner1
            }));
        });

        it('#transferFrom should transfer allowed tokens to address', async () => {
            await pan.approve(owner2, 1000000, {
                from: owner1
            });
            const amountToTransfer = 1000;
            const transferResult = await pan.transferFrom(owner1, owner3, amountToTransfer, {
                from: owner2
            });
            let event = transferResult.logs.filter(l => (
                l.event === 'Transfer' && transferResult.tx === l.transactionHash
            ));
            (event.length).should.equal(1);
            (event[0].args.from).should.equal(owner1);
            (event[0].args.to).should.equal(owner3);
            (event[0].args.value).should.be.bignumber.equal(amountToTransfer);

            const balance3 = await pan.balanceOf(owner3);
            (balance3).should.be.bignumber.equal(amountToTransfer);
        });

        it('#transferFrom should fail if sender has insufficient allowance balance', async () => {
            await pan.approve(owner2, 1000, {
                from: owner1
            });
            await assertRevert(pan.transferFrom(owner1, owner3, 1500, {
                from: owner2
            }));
        });
    });
});
