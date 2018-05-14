const Pandora = artifacts.require('Pandora');

contract('Pandora', accounts => {

    let pandora;

    before('setup', async () => {

        pandora = await Pandora.deployed();
    });

    it('Account #0 should be whitelisted during deployment', async () => {

        const result = await pandora.workerNodeOwners(accounts[0]);
        // console.log(result);

        assert.equal(result, true, 'account #0 should be whitelisted');
    });
});
