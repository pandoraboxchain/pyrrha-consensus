module.exports = async (promise, message = '') => {
    
    try {
        await promise;
        assert.fail('Expected revert not received');
    } catch (error) {
        const revertFound = error.message.search('revert') >= 0;
        assert(revertFound, `${message !== '' ? message+': ' : ''}Expected "revert", got ${error} instead`);
    }
};
