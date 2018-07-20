# ICognitiveJobManager


**Execution cost**: No bound available

**Deployment cost**: No bound available

**Combined cost**: No bound available


## Events
### CognitiveJobCreated(bytes32)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*


## Methods
### activeJobsCount()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### commitProgress(bytes32,uint8)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_percent** *of type `uint8`*


--- 
### getCognitiveJobDetails(bytes32,bool)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_jobId** *of type `bytes32`*
2. **_isActive** *of type `bool`*

Returns:


1. **kernel** *of type `address`*
2. **dataset** *of type `address`*
3. **comlexity** *of type `uint256`*
4. **description** *of type `bytes32`*
5. **activeWorkers** *of type `address[]`*

--- 
### getCognitiveJobProgressInfo(bytes32,bool)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_jobId** *of type `bytes32`*
2. **_isActive** *of type `bool`*

Returns:


1. **responseTimestamps** *of type `uint32[]`*
2. **responseFlags** *of type `bool[]`*
3. **progress** *of type `uint8`*
4. **state** *of type `uint8`*

--- 
### getCognitiveJobResults(bytes32,bool,uint8)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_jobId** *of type `bytes32`*
2. **_isActive** *of type `bool`*
3. **_index** *of type `uint8`*

Returns:


1. **ipfsResults** *of type `bytes`*

--- 
### isActiveJob(bytes32)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_jobId** *of type `bytes32`*

Returns:


1. **output_0** *of type `bool`*

--- 
### provideResults(bytes32,bytes)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_ipfsResults** *of type `bytes`*


--- 
### respondToJob(bytes32,uint8,bool)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_responseType** *of type `uint8`*
3. **_response** *of type `bool`*


[Back to the top ↑](#icognitivejobmanager)
