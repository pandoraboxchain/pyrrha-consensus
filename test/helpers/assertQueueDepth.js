const {
    getQueueDepth
} = require("./cognitive_job_manager");

module.exports = async (pandora, depth) => {
    const queueDepth = await getQueueDepth(pandora);
    assert.equal(queueDepth, depth, `Queue depth should be ${depth}`);
}