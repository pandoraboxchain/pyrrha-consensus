const RandomEngine = artifacts.require('RandomEngine');

contract('RandomEngine', accounts => {

    let max = 9999;
    let engine;

    before('setup test random engine', async () => {
        engine = await RandomEngine.new();
    });

    it('should return different numbers each call', async () => {
        const [r1, r2] =  await Promise.all([
            engine.getRandom.call(max),
            engine.getRandom.call(max),
        ]);
        assert.isOk(r1 !== r2, 'random is the same as previous');
    });
});
