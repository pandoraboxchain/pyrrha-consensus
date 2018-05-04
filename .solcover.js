module.exports = {
    norpc: true,
    dir: '.',
    testCommand: 'npx truffle test --network coverage',
    copyPackages: [
        "zeppelin-solidity"
    ],
    skipFiles: [
        'Migrations.sol'
    ]
}