# CognitiveJobController


**Execution cost**: No bound available

**Deployment cost**: less than 1975200 gas

**Combined cost**: No bound available

## Constructor




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
### activeJobsIndexes(bytes32)


**Execution cost**: less than 669 gas

**Attributes**: constant


Params:

1. **param_0** *of type `bytes32`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### completedJobs(uint256)


**Execution cost**: less than 2096 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **id** *of type `bytes32`*
2. **kernel** *of type `address`*
3. **dataset** *of type `address`*
4. **complexity** *of type `uint256`*
5. **description** *of type `bytes32`*
6. **progress** *of type `uint8`*
7. **state** *of type `uint8`*

--- 
### commitProgress(bytes32,address,uint8)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_workerId** *of type `address`*
3. **_percent** *of type `uint8`*


--- 
### activeJobs(uint256)


**Execution cost**: less than 2118 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **id** *of type `bytes32`*
2. **kernel** *of type `address`*
3. **dataset** *of type `address`*
4. **complexity** *of type `uint256`*
5. **description** *of type `bytes32`*
6. **progress** *of type `uint8`*
7. **state** *of type `uint8`*

--- 
### completeWork(bytes32,address,bytes)
>
>should be called with provided results


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*
2. **_workerId** *of type `address`*
3. **_ipfsResults** *of type `bytes`*

Returns:


1. **result** *of type `bool`*

--- 
### activeJobsCount()
>
> Returns total count of active jobs


**Execution cost**: less than 561 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### owner()


**Execution cost**: less than 801 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### completedJobsIndexes(bytes32)


**Execution cost**: less than 603 gas

**Attributes**: constant


Params:

1. **param_0** *of type `bytes32`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### completedJobsCount()
>
> Returns total count of active jobs


**Execution cost**: less than 714 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### createCognitiveJob(bytes32,address,address,address[],uint256,bytes32)
>
>**************************************************************************************************************** External functions (Only Pandora by interface)


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
### getCognitiveJobResults(bytes32,uint8)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_jobId** *of type `bytes32`*
2. **_index** *of type `uint8`*

Returns:


1. **ipfsResults** *of type `bytes`*

--- 
### getCognitiveJobServiceInfo(bytes32)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_jobId** *of type `bytes32`*

Returns:


1. **responseTimestamps** *of type `uint32[]`*
2. **responseFlags** *of type `bool[]`*

--- 
### getJobId(uint16,bool)


**Execution cost**: less than 995 gas

**Attributes**: constant


Params:

1. **_index** *of type `uint16`*
2. **_isActive** *of type `bool`*

Returns:


1. **output_0** *of type `bytes32`*

--- 
### renounceOwnership()
>
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22361 gas




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
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23203 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### transitionTable(uint8,uint256)


**Execution cost**: less than 2786 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint8`*
2. **param_1** *of type `uint256`*

Returns:


1. **output_0** *of type `uint8`*

[Back to the top ↑](#cognitivejobcontroller)
