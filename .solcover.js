module.exports = {
    norpc: true,
    compileCommand: 'npx truffle compile',
    testCommand: 'npx --node-arg=--max-old-space-size=4096 truffle test --network coverage',
    copyPackages: [
        "zeppelin-solidity"
    ],
    skipFiles: [
        'Migrations.sol'
    ]
};
