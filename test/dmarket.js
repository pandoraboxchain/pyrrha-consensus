let DMarket = artifacts.require("PandoraMarket")
let Dataset = artifacts.require("Dataset")
let Kernel = artifacts.require("Kernel")

contract('Pandora dMarket', accounts => {
  let dmarket = {}
  let addedAddress = null

  before('getting deployed contract', async () => {
    dmarket = await DMarket.deployed()
  })

  it('should have constants properly defined', async () => {
    assert.equal(await dmarket.STATUS_FAILED_CONTRACT(), 0,
      'constant indicating failed contract state must be equal to zero')
  })

  it('should not contain only pre-populated data originally', async () => {
    assert.equal((await dmarket.kernelsCount()).toNumber(), 1, 'should be a single kernels')
    assert.equal((await dmarket.datasetsCount()).toNumber(), 1, 'should be a single datasets')
  })

  it('should add a first kernel', async () => {
    let newKernel = await Kernel.new('', 0, 0, 0)
    addedAddress = newKernel.address

    let receipt = await dmarket.addKernel(newKernel.address)
    let logSuccess = receipt.logs.filter(l => l.event === 'KernelAdded')[0]
    let logFailure = receipt.logs.filter(l => l.event === 'KernelAddFailure')[0]
    let logEntries = receipt.logs.length

    assert.equal(logEntries, 1, 'should be only a single log entry generated')
    assert.isOk(logSuccess, 'kernel creation should be successful')
    assert.isNotOk(logFailure, 'there should be no report of failure in logs')

    assert.equal((await dmarket.kernelsCount()).toNumber(), 2, 'there should be now one kernel registered')

    assert.equal(await dmarket.kernels(1), logSuccess.args.kernel,
      'address from the log should appear in the registry at the last position')
    assert.equal(logSuccess.args.kernel, newKernel.address,
      'address from the log should be equal to the returned contract address')
    assert.equal(await dmarket.kernelMap(newKernel.address), 2,
      'should return correct position for the added address')
  })

  it('should remove a single kernel', async () => {
    console.log('Trying to remove kernel address ' + addedAddress)

    let receipt = await dmarket.removeKernel(addedAddress)
    let logSuccess = receipt.logs.filter(l => l.event === 'KernelRemoved')[0]
    let logFailure = receipt.logs.filter(l => l.event === 'KernelRemoveFailure')[0]
    let logEntries = receipt.logs.length

    assert.equal(logEntries, 1, 'should be only a single log entry generated')
    assert.isOk(logSuccess, 'kernel deletion should be successful')
    assert.isNotOk(logFailure, 'there should be no report of failure in logs')

    assert.equal((await dmarket.kernelsCount()).toNumber(), 1, 'there should be no kernels left in the registry')
    assert.equal(dmarket.kernelMap(newKernel.address), 0, 'should not point to any index')
  })
})
