# CognitiveJob


**Execution cost**: No bound available

**Deployment cost**: less than 1674800 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_pandora** *of type `address`*
2. **_kernel** *of type `address`*
3. **_dataset** *of type `address`*
4. **_workersPool** *of type `address[]`*

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
### Flag(uint256)


**Execution cost**: No bound available


Params:

1. **number** *of type `uint256`*

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


**Execution cost**: less than 193 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Completed()


**Execution cost**: less than 787 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Destroyed()


**Execution cost**: less than 677 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Cognition()


**Execution cost**: less than 281 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### DataValidation()


**Execution cost**: less than 655 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientWorkers()


**Execution cost**: less than 633 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### GatheringWorkers()


**Execution cost**: less than 347 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InvalidData()


**Execution cost**: less than 457 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### dataValidationResponse(uint8)


**Execution cost**: No bound available


Params:

1. **_response** *of type `uint8`*


--- 
### completeWork(bytes)


**Execution cost**: No bound available


Params:

1. **_ipfsResults** *of type `bytes`*


--- 
### activeWorkers(uint256)


**Execution cost**: less than 1079 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### activeWorkersCount()


**Execution cost**: less than 560 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### batches()


**Execution cost**: less than 916 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Uninitialized()


**Execution cost**: less than 325 gas

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


**Execution cost**: less than 559 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### currentState()
>
>Returns current state of the contract state machine
>
> Shortcut to receive current state from external contracts


**Execution cost**: less than 455 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### kernel()


**Execution cost**: less than 1065 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### destroyAndSend(address)


**Execution cost**: less than 31227 gas


Params:

1. **_recipient** *of type `address`*


--- 
### destroy()
>
> Transfers the current balance to the owner and terminates the contract.


**Execution cost**: less than 31082 gas




--- 
### didWorkerCompute(uint256)


**Execution cost**: less than 2927 gas

**Attributes**: constant


Params:

1. **no** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### gatheringWorkersResponse(bool)


**Execution cost**: No bound available


Params:

1. **_acceptanceFlag** *of type `bool`*


--- 
### initialize()


**Execution cost**: No bound available




--- 
### owner()


**Execution cost**: less than 933 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### pandora()


**Execution cost**: less than 647 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### progress()


**Execution cost**: less than 619 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### reportOfflineWorker(address)
>
> Main entry point for (Witnessing worker nodes went offline)[https://github.com/pandoraboxchain/techspecs/wiki/Witnessing-worker-nodes-going-offline] workflow


**Execution cost**: No bound available

**Attributes**: payable


Params:

1. **_reportedWorker** *of type `address`*


--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23359 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### workersPool(uint256)


**Execution cost**: less than 1123 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

[Back to the top ↑](#cognitivejob)
