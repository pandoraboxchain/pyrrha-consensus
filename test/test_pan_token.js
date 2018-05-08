const PAN = artifacts.require('PAN');

contract('PAN', accounts => {

    let pan;

    before('setup', async () => {
        pan = await PAN.new();
    });

    it('#totalSupply should return INITIAL_SUPPLY', async () => {

        const totalSupply = await pan.totalSupply();
        assert.equal(totalSupply.toNumber(), 5000000 * 100000000);
    });
});
