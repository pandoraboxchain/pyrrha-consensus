# Pandora


**Execution cost**: No bound available

**Deployment cost**: No bound available

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
### WorkerNodeCreated(address)


**Execution cost**: No bound available


Params:

1. **workerNode** *of type `address`*

--- 
### WorkerNodeDestroyed(address)


**Execution cost**: No bound available


Params:

1. **workerNode** *of type `address`*

--- 
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*


## Methods
### workerNodesCount()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### whitelistWorkerOwner(address)


**Execution cost**: No bound available


Params:

1. **_workerOwner** *of type `address`*


--- 
### initialized()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `bool`*

--- 
### workerNodes(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### penaltizeWorkerNode()


**Execution cost**: No bound available




--- 
### RESULT_CODE_JOB_CREATED()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### jobController()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### version()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### penaltizeWorkerNode(address,uint8)


**Execution cost**: No bound available


Params:

1. **guilty** *of type `address`*
2. **reason** *of type `uint8`*


--- 
### commitProgress(bytes32,uint8)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_percent** *of type `uint8`*


--- 
### workerNodeOwners(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `bool`*

--- 
### renounceOwnership()


**Execution cost**: No bound available




--- 
### blacklistWorkerOwner(address)


**Execution cost**: No bound available


Params:

1. **_workerOwner** *of type `address`*


--- 
### getQueueDepth()


**Execution cost**: No bound available



Returns:


1. **output_0** *of type `uint256`*

--- 
### initialize()


**Execution cost**: No bound available




--- 
### RESULT_CODE_ADD_TO_QUEUE()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### createWorkerNode()


**Execution cost**: No bound available



Returns:


1. **output_0** *of type `address`*

--- 
### owner()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### isOwner()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `bool`*

--- 
### checkJobQueue()


**Execution cost**: No bound available




--- 
### destroyWorkerNode(address)


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


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### reputation()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### createCognitiveJob(address,address,uint256,bytes32)


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
### transferOwnership(address)


**Execution cost**: No bound available


Params:

1. **newOwner** *of type `address`*


--- 
### workerNodeFactory()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### deposits(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### workerAddresses(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

[Back to the top ↑](#pandora)
