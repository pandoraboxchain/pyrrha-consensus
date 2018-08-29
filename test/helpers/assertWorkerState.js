const {
    WORKER_STATES,
} = require("../constants");

module.exports = async (workerInstance, state, index = "#") => {
    const workerState = await workerInstance.currentState.call();
    assert.equal(
        WORKER_STATES[workerState.toNumber()],
        WORKER_STATES[state],
        `Worker (${index}) state should be ${WORKER_STATES[state]} (${state})`);
}
