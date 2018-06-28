# CognitiveJobManager
> Pandora Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: No bound available

**Deployment cost**: less than 1595800 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_jobFactory** *of type `address`*
2. **_nodeFactory** *of type `address`*
3. **_reputation** *of type `address`*

## Events
### DebugEvent3(bytes32)


**Execution cost**: No bound available


Params:

1. **descr** *of type `bytes32`*

--- 
### CognitiveJobCreated(address,uint256)


**Execution cost**: No bound available


Params:

1. **cognitiveJob** *of type `address`*
2. **resultCode** *of type `uint256`*

--- 
### CognitiveJobCreateFailed(address,uint256)


**Execution cost**: No bound available


Params:

1. **cognitiveJob** *of type `address`*
2. **resultCode** *of type `uint256`*

--- 
### CognitiveJobCreated(address)


**Execution cost**: No bound available


Params:

1. **cognitiveJob** *of type `address`*

--- 
### DebugEvent(uint256)


**Execution cost**: No bound available


Params:

1. **value** *of type `uint256`*

--- 
### DebugEvent1(address)


**Execution cost**: No bound available


Params:

1. **addr** *of type `address`*

--- 
### DebugEvent2(address[])


**Execution cost**: No bound available


Params:

1. **nodes** *of type `address[]`*

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
### WorkerNodeCreated(address)


**Execution cost**: No bound available


Params:

1. **workerNode** *of type `address`*

--- 
### WorkerNodeDestroyed(address)


**Execution cost**: No bound available


Params:

1. **workerNode** *of type `address`*


## Methods
### initialize()


**Execution cost**: less than 20703 gas




--- 
### isActiveJob(address)
>
>### Public and externalTest whether the given `job` is registered as an active job by the main Pandora contract
>
> Used to test if some given job contract is a contract created by the Pandora and is listed by it as an active contract


**Execution cost**: less than 1594 gas

**Attributes**: constant


Params:

1. **_job** *of type `address`*

Returns:


1. **output_0** *of type `bool`*

--- 
### deposits(address)


**Execution cost**: less than 1122 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### initialized()


**Execution cost**: less than 525 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bool`*

--- 
### finishCognitiveJob()
>
>Can"t be called by the user, for internal use only
>
> Function must be called only by the master node running cognitive job. It completes the job, updates worker node back to `Idle` state (in smart contract) and removes job contract from the list of active contracts


**Execution cost**: No bound available




--- 
### createCognitiveJob(address,address,uint256,bytes32)
>
>Creates and returns new cognitive job contract and starts actual cognitive work instantly
>
> Core function creating new cognitive job contract and returning it back to the caller


**Execution cost**: No bound available

**Attributes**: payable


Params:

1. **_kernel** *of type `address`*
2. **_dataset** *of type `address`*
3. **_complexity** *of type `uint256`*
4. **_description** *of type `bytes32`*

Returns:


1. **o_cognitiveJob** *of type `address`*
2. **o_resultCode** *of type `uint8`*

--- 
### RESULT_CODE_JOB_CREATED()


**Execution cost**: less than 388 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### cognitiveJobFactory()


**Execution cost**: less than 754 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### REQUIRED_DEPOSIT()


**Execution cost**: less than 687 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### cognitiveJobs(uint256)


**Execution cost**: less than 1318 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### destroyWorkerNode(address)
>
>Removes worker from the workers list and destroys it. Can be called only by the worker node owner and only for the idle workers


**Execution cost**: No bound available


Params:

1. **_workerNode** *of type `address`*


--- 
### cognitiveJobsCount()
>
> Returns total count of active jobs


**Execution cost**: less than 1061 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### blacklistWorkerOwner(address)
>
>Removes address from the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 21194 gas


Params:

1. **_workerOwner** *of type `address`*


--- 
### createWorkerNode()
>
>Creates, registers and returns a new worker node owned by the caller of the contract. Can be called only by the whitelisted node owner address.


**Execution cost**: No bound available



Returns:


1. **output_0** *of type `address`*

--- 
### RESULT_CODE_ADD_TO_QUEUE()


**Execution cost**: less than 564 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### jobAddresses(address)


**Execution cost**: less than 785 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### workerAddresses(address)


**Execution cost**: less than 1159 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### renounceOwnership()
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22380 gas




--- 
### whitelistWorkerOwner(address)
>
>### Public and externalAdds address to the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 20980 gas


Params:

1. **_workerOwner** *of type `address`*


--- 
### penaltizeWorkerNode(address,uint8)


**Execution cost**: less than 723 gas


Params:

1. **_guiltyWorker** *of type `address`*
2. **_reason** *of type `uint8`*


--- 
### owner()


**Execution cost**: less than 952 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23307 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### workerNodeFactory()


**Execution cost**: less than 1106 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### workerNodeOwners(address)


**Execution cost**: less than 826 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `bool`*

--- 
### workerNodes(uint256)


**Execution cost**: less than 1010 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### workerNodesCount()
>
>Returns count of registered worker nodes


**Execution cost**: less than 710 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

[Back to the top ↑](#cognitivejobmanager)
