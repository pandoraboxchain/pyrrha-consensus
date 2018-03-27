let Pandora = artifacts.require("Pandora") // *** NB: version with hooks (for testing) instead of normal contract)
let Dataset = artifacts.require("Dataset")
let Kernel = artifacts.require("Kernel")
let WorkerNode = artifacts.require("WorkerNode")


contract('Pandora', accounts => {

  let pandora;
  let pandoraAddress;
  let workerNode;
  const client = accounts[5]

  before('setup', async () => {
    pandora = await Pandora.deployed()

    await pandora.whitelistWorkerOwner(accounts[0])
    workerNode = await pandora.createWorkerNode({from: accounts[0]})

    const idleWorkerAddress = await pandora.workerNodes.call(0)
    console.log(idleWorkerAddress, 'worker node')

    let idleWorkerInstance = await WorkerNode.at(idleWorkerAddress)
    let workerAliveResult = await idleWorkerInstance.alive({from: accounts[2]})
  })

  it('Should not create job if # of idle workers < number of batches', async () => {

    let numberOfBatches = 5
    let testDataset = await Dataset.new('', 1, 0, numberOfBatches, 0)
    let testKernel = await Kernel.new('', 1, 0, 0)
    let estimatedCode = 0

    let result = await pandora.createCognitiveJob(testKernel.address, testDataset.address)

    let logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0]
    let logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0]
    let logEntries = result.logs.length

    console.log(logFailure, "failure")
    console.log(logSuccess, "success")
    console.log(logEntries, "entries")

    assert.equal(result.logs[0].args.resultCode, estimatedCode, "result code in event should match RESULT_CODE_ADD_TO_QUEUE" )
    assert.equal(logEntries, 1, "should be fired only 1 event")
    assert.isOk(logFailure, "should be fired failed event")
    assert.isNotOk(logSuccess, "should not be fired successful creation event")
  })

  it('Should create job if number of idle workers >= number of batches in dataset', async () => {

    let numberOfBatches = 1
    let testDataset = await Dataset.new('', 1, 0, numberOfBatches, 0)
    let testKernel = await Kernel.new('', 1, 0, 0)
    let estimatedCode = 1

    let result = await pandora.createCognitiveJob(testKernel.address, testDataset.address)

    let logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0]
    let logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0]
    let logEntries = result.logs.length

    console.log(logFailure, "failure")
    console.log(logSuccess, "success")
    console.log(logEntries, "entries")

    assert.equal(result.logs[1].args.resultCode, estimatedCode, "result code in event should match RESULT_CODE_JOB_CREATED" )
    assert.equal(logEntries, 2, "should be fired only 2 events")
    assert.isNotOk(logFailure, "should not be fired failed event")
    assert.isOk(logSuccess, "should be fired successful creation event")
  })

//  it('Should request cognitive job from queue when computation is finished', async () => {
//
//    console.log(accounts[0])
//    let result = await pandora.finishCognitiveJob({from: accounts[3]})
//    console.log(result);
//
//  })
})