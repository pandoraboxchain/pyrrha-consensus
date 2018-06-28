# CognitiveJob


**Execution cost**: No bound available

**Deployment cost**: less than 1842400 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_pandora** *of type `address`*
2. **_kernel** *of type `address`*
3. **_dataset** *of type `address`*
4. **_workersPool** *of type `address[]`*
5. **_complexity** *of type `uint256`*
6. **_description** *of type `bytes32`*

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
### OwnershipRenounced(address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*

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
### renounceOwnership()
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22537 gas




--- 
### PartialResult()


**Execution cost**: less than 193 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Completed()


**Execution cost**: less than 919 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Destroyed()


**Execution cost**: less than 809 gas

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


**Execution cost**: less than 787 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientWorkers()


**Execution cost**: less than 765 gas

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


**Execution cost**: less than 501 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### destroy()
>
> Transfers the current balance to the owner and terminates the contract.


**Execution cost**: less than 31180 gas




--- 
### destroyAndSend(address)


**Execution cost**: less than 31347 gas


Params:

1. **_recipient** *of type `address`*


--- 
### completeWork(bytes)


**Execution cost**: No bound available


Params:

1. **_ipfsResults** *of type `bytes`*


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
### activeWorkers(uint256)


**Execution cost**: less than 1123 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### complexity()


**Execution cost**: less than 560 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### batches()


**Execution cost**: less than 1022 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### Uninitialized()


**Execution cost**: less than 325 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### commitProgress(uint8)


**Execution cost**: No bound available


Params:

1. **_percent** *of type `uint8`*


--- 
### dataset()


**Execution cost**: less than 559 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### description()


**Execution cost**: less than 802 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### dataValidationResponse(uint8)


**Execution cost**: No bound available


Params:

1. **_response** *of type `uint8`*


--- 
### activeWorkersCount()


**Execution cost**: less than 604 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### workersPool(uint256)


**Execution cost**: less than 1167 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### initialize()


**Execution cost**: No bound available




--- 
### didWorkerCompute(uint256)


**Execution cost**: less than 3290 gas

**Attributes**: constant


Params:

1. **no** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### gatheringWorkersResponse(bool)


**Execution cost**: No bound available


Params:

1. **_flag** *of type `bool`*


--- 
### ipfsResults(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `bytes`*

--- 
### ipfsResultsCount()


**Execution cost**: less than 582 gas

**Attributes**: constant



Returns:


1. **count** *of type `uint256`*

--- 
### jobType()


**Execution cost**: less than 824 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### kernel()


**Execution cost**: less than 1197 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### owner()


**Execution cost**: less than 1043 gas

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


**Execution cost**: less than 663 gas

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


**Execution cost**: less than 23577 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### transitionToState(uint8)
>
> State transition function


**Execution cost**: No bound available


Params:

1. **_newState** *of type `uint8`*


[Back to the top ↑](#cognitivejob)
