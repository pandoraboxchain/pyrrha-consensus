# CognitiveJob


**Execution cost**: No bound available

**Deployment cost**: less than 1861600 gas

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


**Execution cost**: less than 22559 gas




--- 
### PartialResult()


**Execution cost**: less than 193 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Completed()


**Execution cost**: less than 963 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Destroyed()


**Execution cost**: less than 853 gas

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


**Execution cost**: less than 831 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientWorkers()


**Execution cost**: less than 809 gas

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


**Execution cost**: less than 523 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### owner()


**Execution cost**: less than 1065 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### isAllWorkersAccepted()


**Execution cost**: No bound available



Returns:


1. **accepted** *of type `bool`*

--- 
### activeWorkersCount()


**Execution cost**: less than 626 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### completeWork(bytes)


**Execution cost**: No bound available


Params:

1. **_ipfsResults** *of type `bytes`*


--- 
### destroyAndSend(address)


**Execution cost**: less than 31391 gas


Params:

1. **_recipient** *of type `address`*


--- 
### activeWorkers(uint256)


**Execution cost**: less than 1145 gas

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
### gatheringWorkersResponse(bool)


**Execution cost**: No bound available


Params:

1. **_flag** *of type `bool`*


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


**Execution cost**: less than 824 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### didWorkerCompute(uint256)


**Execution cost**: less than 3334 gas

**Attributes**: constant


Params:

1. **no** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### initialize()


**Execution cost**: No bound available




--- 
### destroy()
>
> Transfers the current balance to the owner and terminates the contract.


**Execution cost**: less than 31202 gas




--- 
### ipfsResultsCount()


**Execution cost**: less than 604 gas

**Attributes**: constant



Returns:


1. **count** *of type `uint256`*

--- 
### batches()


**Execution cost**: less than 1066 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### ipfsResults(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `bytes`*

--- 
### dataValidationResponse(uint8)


**Execution cost**: No bound available


Params:

1. **_response** *of type `uint8`*


--- 
### Uninitialized()


**Execution cost**: less than 325 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### isAllWorkersCompleted()


**Execution cost**: No bound available



Returns:


1. **completed** *of type `bool`*

--- 
### isAllWorkersValidated()


**Execution cost**: No bound available



Returns:


1. **validated** *of type `bool`*

--- 
### jobType()


**Execution cost**: less than 846 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### kernel()


**Execution cost**: less than 1241 gas

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


**Execution cost**: less than 685 gas

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


**Execution cost**: less than 23621 gas


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


--- 
### workersPool(uint256)


**Execution cost**: less than 1189 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

[Back to the top ↑](#cognitivejob)
