// const CognitiveJob = artifacts.require('CognitiveJob');

const {
    JOB_STATES,
} = require("../constants");

module.exports = async (activeJob, state, index = "#") => {
    const jobState = await CognitiveJob.at(activeJob).currentState.call();
    assert.equal(
        JOB_STATES[jobState.toNumber()],
        JOB_STATES[state],
        `Cognitive job (${index}) state should be ${JOB_STATES[state]} (${state})`);
}