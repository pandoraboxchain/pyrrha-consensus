# CognitiveJobManager
> Pandora Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: No bound available

**Deployment cost**: less than 1608800 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_jobFactory** *of type `address`*
2. **_nodeFactory** *of type `address`*

## Events
### CognitiveJobCreateFailed(address,uint256)


**Execution cost**: No bound available


Params:

1. **cognitiveJob** *of type `address`*
2. **resultCode** *of type `uint256`*

--- 
### CognitiveJobCreated(address,uint256)


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
### workerNodeOwners(address)


**Execution cost**: less than 870 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `bool`*

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
### createCognitiveJob(address,address)
>
>Creates and returns new cognitive job contract and starts actual cognitive work instantly
>
> Core function creating new cognitive job contract and returning it back to the caller


**Execution cost**: No bound available

**Attributes**: payable


Params:

1. **_kernel** *of type `address`*
2. **_dataset** *of type `address`*

Returns:


1. **o_cognitiveJob** *of type `address`*
2. **o_resultCode** *of type `uint8`*

--- 
### initialized()


**Execution cost**: less than 525 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bool`*

--- 
### finishCognitiveJob()
>
>Can't be called by the user, for internal use only
>
> Function must be called only by the master node running cognitive job. It completes the job, updates worker node back to `Idle` state (in smart contract) and removes job contract from the list of active contracts


**Execution cost**: No bound available




--- 
### getRandomArray(uint256,uint256)


**Execution cost**: No bound available


Params:

1. **_arrayLength** *of type `uint256`*
2. **_numbersRange** *of type `uint256`*

Returns:


1. **o_result** *of type `uint256[]`*

--- 
### activeJobs(uint256)


**Execution cost**: less than 1032 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### RESULT_CODE_JOB_CREATED()


**Execution cost**: less than 410 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### cognitiveJobFactory()


**Execution cost**: less than 776 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### activeJobsCount()
>
> Returns total count of active jobs


**Execution cost**: less than 885 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### destroyWorkerNode(address)
>
>Removes worker from the workers list and destroys it. Can be called only by the worker node owner and only for the idle workers


**Execution cost**: No bound available


Params:

1. **_workerNode** *of type `address`*


--- 
### createWorkerNode()
>
>Creates, registers and returns a new worker node owned by the caller of the contract. Can be called only by the whitelisted node owner address.


**Execution cost**: No bound available



Returns:


1. **output_0** *of type `address`*

--- 
### RESULT_CODE_ADD_TO_QUEUE()


**Execution cost**: less than 586 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### blacklistWorkerOwner(address)
>
>Removes address from the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 21228 gas


Params:

1. **_workerOwner** *of type `address`*


--- 
### initialize()


**Execution cost**: less than 20725 gas




--- 
### jobAddresses(address)


**Execution cost**: less than 829 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### owner()


**Execution cost**: less than 974 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### penaltizeWorkerNode(address,uint8)


**Execution cost**: less than 767 gas


Params:

1. **_guiltyWorker** *of type `address`*
2. **_reason** *of type `uint8`*


--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23315 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### whitelistWorkerOwner(address)
>
>### Public and externalAdds address to the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 20992 gas


Params:

1. **_workerOwner** *of type `address`*


--- 
### workerAddresses(address)


**Execution cost**: less than 1115 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### workerNodeFactory()


**Execution cost**: less than 1084 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

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
