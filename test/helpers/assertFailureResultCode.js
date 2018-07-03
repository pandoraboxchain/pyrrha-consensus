module.exports = (result, code) => {
    assert.equal(
        result.logs[0].args.resultCode,
        code,
        `Result code in event should match ${code}`);
}