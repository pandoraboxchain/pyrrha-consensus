module.exports = {
    norpc: false,
    dir: '.',
    testCommand: 'npx truffle test --network coverage',
    copyPackages: [
        "zeppelin-solidity"
    ],
    skipFiles: [
        'Migrations.sol'
    ]
};
