# ICognitiveJobController


**Execution cost**: No bound available

**Deployment cost**: No bound available

**Combined cost**: No bound available


## Events
### CognitionCompleted(bytes32,bool)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*
2. **partialResult** *of type `bool`*

--- 
### CognitionProgressed(bytes32,uint8)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*
2. **precent** *of type `uint8`*

--- 
### CognitionStarted(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### DataValidationFailed(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### DataValidationStarted(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### JobStateChanged(bytes32,uint8,uint8)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*
2. **oldState** *of type `uint8`*
3. **newState** *of type `uint8`*

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
### WorkersNotFound(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### WorkersUpdated(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*


## Methods
### activeJobsCount()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### commitProgress(bytes32,address,uint8)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_workerId** *of type `address`*
3. **_percent** *of type `uint8`*


--- 
### completeWork(bytes32,address,bytes)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_workerId** *of type `address`*
3. **_ipfsResults** *of type `bytes`*

Returns:


1. **result** *of type `bool`*

--- 
### completedJobsCount()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### createCognitiveJob(bytes32,address,address,address[],uint256,bytes32)


**Execution cost**: No bound available


Params:

1. **_id** *of type `bytes32`*
2. **_kernel** *of type `address`*
3. **_dataset** *of type `address`*
4. **_assignedWorkers** *of type `address[]`*
5. **_complexity** *of type `uint256`*
6. **_description** *of type `bytes32`*


--- 
### getCognitiveJobDetails(bytes32)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_jobId** *of type `bytes32`*

Returns:


1. **kernel** *of type `address`*
2. **dataset** *of type `address`*
3. **complexity** *of type `uint256`*
4. **description** *of type `bytes32`*
5. **activeWorkers** *of type `address[]`*
6. **progress** *of type `uint8`*
7. **state** *of type `uint8`*

--- 
### owner()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### renounceOwnership()


**Execution cost**: No bound available




--- 
### respondToJob(bytes32,address,uint8,bool)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_workerId** *of type `address`*
3. **_responseType** *of type `uint8`*
4. **_response** *of type `bool`*

Returns:


1. **result** *of type `bool`*

--- 
### transferOwnership(address)


**Execution cost**: No bound available


Params:

1. **_newOwner** *of type `address`*


[Back to the top ↑](#icognitivejobcontroller)
