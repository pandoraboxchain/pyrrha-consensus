# Pandora
> Pandora Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: No bound available

**Deployment cost**: less than 1788000 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_jobController** *of type `address`*
2. **_nodeFactory** *of type `address`*
3. **_reputation** *of type `address`*

## Events
### CognitiveJobCreated(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### CognitiveJobQueued(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### Debug(address)


**Execution cost**: No bound available


Params:

1. **worker** *of type `address`*

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
### RESULT_CODE_ADD_TO_QUEUE()


**Execution cost**: less than 564 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### workerAddresses(address)


**Execution cost**: less than 1203 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### initialized()


**Execution cost**: less than 503 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bool`*

--- 
### deposits(address)


**Execution cost**: less than 1166 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### RESULT_CODE_JOB_CREATED()


**Execution cost**: less than 344 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### jobController()


**Execution cost**: less than 710 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### version()


**Execution cost**: less than 379 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### penaltizeWorkerNode(address,uint8)


**Execution cost**: less than 679 gas


Params:

1. **_guiltyWorker** *of type `address`*
2. **_reason** *of type `uint8`*


--- 
### commitProgress(bytes32,uint8)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_percent** *of type `uint8`*


--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23384 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### renounceOwnership()
>
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22377 gas




--- 
### blacklistWorkerOwner(address)
>
>Removes address from the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 21183 gas


Params:

1. **_workerOwner** *of type `address`*


--- 
### getQueueDepth()


**Execution cost**: less than 961 gas



Returns:


1. **output_0** *of type `uint256`*

--- 
### initialize()
>
>### InitializationFunction that checks the proper setup of class factories. May be called only once and only by Pandora contract owner.
>
> Function that checks the proper setup of class factories. May be called only once and only by Pandora contract owner.


**Execution cost**: No bound available




--- 
### whitelistWorkerOwner(address)
>
>### Public and externalAdds address to the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 20969 gas


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
### owner()


**Execution cost**: less than 963 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### checkJobQueue()
>
>### PublicPublic function which checks queue of jobs and create new jobs #dev Function is called by worker owner, after finalize congitiveJob (but could be called by any address) to unlock worker's idle state and allocate newly freed WorkerNodes to perform cognitive jobs from the queue.


**Execution cost**: No bound available




--- 
### destroyWorkerNode(address)
>
>Removes worker from the workers list and destroys it. Can be called only by the worker node owner and only for the idle workers


**Execution cost**: No bound available


Params:

1. **_workerNode** *of type `address`*


--- 
### respondToJob(bytes32,uint8,bool)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_responseType** *of type `uint8`*
3. **_response** *of type `bool`*


--- 
### provideResults(bytes32,bytes)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_ipfsResults** *of type `bytes`*


--- 
### REQUIRED_DEPOSIT()


**Execution cost**: less than 709 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### reputation()


**Execution cost**: less than 1084 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

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


1. **o_jobId** *of type `bytes32`*
2. **o_resultCode** *of type `uint8`*

--- 
### workerNodeFactory()


**Execution cost**: less than 1150 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### workerNodeOwners(address)


**Execution cost**: less than 804 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `bool`*

--- 
### workerNodes(uint256)


**Execution cost**: less than 966 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### workerNodesCount()
>
>Returns count of registered worker nodes


**Execution cost**: less than 697 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

[Back to the top ↑](#pandora)
