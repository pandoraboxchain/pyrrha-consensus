# IComputingJob


**Execution cost**: No bound available

**Deployment cost**: No bound available

**Combined cost**: No bound available


## Events
### CognitionCompleted(bool)


**Execution cost**: No bound available


Params:

1. **partialResult** *of type `bool`*

--- 
### CognitionProgressed(uint8)


**Execution cost**: No bound available


Params:

1. **precent** *of type `uint8`*

--- 
### CognitionStarted()


**Execution cost**: No bound available



--- 
### DataValidationFailed()


**Execution cost**: No bound available



--- 
### DataValidationStarted()


**Execution cost**: No bound available



--- 
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*

--- 
### StateChanged(uint8,uint8)


**Execution cost**: No bound available


Params:

1. **oldState** *of type `uint8`*
2. **newState** *of type `uint8`*

--- 
### WorkersNotFound()


**Execution cost**: No bound available



--- 
### WorkersUpdated()


**Execution cost**: No bound available




## Methods
### commitProgress(uint8)


**Execution cost**: No bound available


Params:

1. **percent** *of type `uint8`*


--- 
### PartialResult()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Completed()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Destroyed()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Cognition()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### DataValidation()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientWorkers()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### GatheringWorkers()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InvalidData()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### dataValidationResponse(uint8)


**Execution cost**: No bound available


Params:

1. **response** *of type `uint8`*


--- 
### completeWork(bytes)


**Execution cost**: No bound available


Params:

1. **ipfs** *of type `bytes`*


--- 
### activeWorkers(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### activeWorkersCount()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### batches()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Uninitialized()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### ipfsResults(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `bytes`*

--- 
### dataset()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### currentState()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### kernel()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### destroyAndSend(address)


**Execution cost**: No bound available


Params:

1. **_recipient** *of type `address`*


--- 
### destroy()


**Execution cost**: No bound available




--- 
### didWorkerCompute(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **no** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### gatheringWorkersResponse(bool)


**Execution cost**: No bound available


Params:

1. **acceptanceFlag** *of type `bool`*


--- 
### initialize()


**Execution cost**: No bound available




--- 
### owner()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### pandora()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### progress()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### reportOfflineWorker(address)


**Execution cost**: No bound available

**Attributes**: payable


Params:

1. **reported** *of type `address`*


--- 
### transferOwnership(address)


**Execution cost**: No bound available


Params:

1. **newOwner** *of type `address`*


--- 
### workersPool(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

[Back to the top ↑](#icomputingjob)
