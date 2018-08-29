const {
    INVALID_OPCODE,
    OUT_OF_GAS,
    REVERT,
    IS_NOT_CONTRACT
} = require("../constants");

module.exports = async (promise, errorType) => {

    try {
        await promise;
    } catch (error) {
        
        // TODO: Check jump destination to destinguish between a throw
        //       and an actual invalid jump.
        const invalidOpcode = error.message.search('invalid opcode') >= 0;
        const isNotContract = error.message.search('is not a contract address') >= 0;
        // TODO: When we contract A calls contract B, and B throws, instead
        //       of an 'invalid jump', we get an 'out of gas' error. How do
        //       we distinguish this from an actual out of gas event? (The
        //       ganache log actually show an 'invalid jump' event.)
        const outOfGas = error.message.search('out of gas') >= 0;
        const revert = error.message.search('revert') >= 0;

        const msg = 'Expected throw, got \'' + error + '\' instead';

        switch (errorType) {
            case INVALID_OPCODE:
                assert(invalidOpcode, msg);
                return;

            case OUT_OF_GAS:
                assert(outOfGas, msg);
                return;

            case REVERT:
                assert(revert, msg);
                return;
            
            case IS_NOT_CONTRACT:
                assert(isNotContract, msg);
                return;

            default:
                assert(invalidOpcode || outOfGas || revert || isNotContract, msg);
                return;
        }
    }
    assert.fail('Expected throw not received');
};
