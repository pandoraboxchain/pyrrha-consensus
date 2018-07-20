# IWorkerNode


**Execution cost**: No bound available

**Deployment cost**: No bound available

**Combined cost**: No bound available


## Events
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
### WorkerDestroyed()


**Execution cost**: No bound available




## Methods
### assignJob(bytes32)


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*


--- 
### processToCognition()


**Execution cost**: No bound available




--- 
### declineValidData()


**Execution cost**: No bound available




--- 
### Uninitialized()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Computing()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### ReadyForComputing()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Assigned()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientStake()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### acceptValidData()


**Execution cost**: No bound available




--- 
### acceptAssignment()


**Execution cost**: No bound available




--- 
### Destroyed()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### ValidatingData()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### alive()


**Execution cost**: No bound available




--- 
### ReadyForDataValidation()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### currentState()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Offline()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### destroy()


**Execution cost**: No bound available




--- 
### owner()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### activeJob()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### UnderPenalty()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Idle()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### cancelJob()


**Execution cost**: No bound available




--- 
### declineAssignment()


**Execution cost**: No bound available




--- 
### processToDataValidation()


**Execution cost**: No bound available




--- 
### provideResults(bytes)


**Execution cost**: No bound available


Params:

1. **_ipfsAddress** *of type `bytes`*


--- 
### renounceOwnership()


**Execution cost**: No bound available




--- 
### reportInvalidData()


**Execution cost**: No bound available




--- 
### transferOwnership(address)


**Execution cost**: No bound available


Params:

1. **_newOwner** *of type `address`*


--- 
### withdrawBalance()


**Execution cost**: No bound available




[Back to the top ↑](#iworkernode)
