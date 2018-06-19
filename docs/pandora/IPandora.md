# IPandora


**Execution cost**: No bound available

**Deployment cost**: No bound available

**Combined cost**: No bound available


## Events
### Approval(address,address,uint256)


**Execution cost**: No bound available


Params:

1. **owner** *of type `address`*
2. **spender** *of type `address`*
3. **value** *of type `uint256`*

--- 
### CognitiveJobCreated(address)


**Execution cost**: No bound available


Params:

1. **cognitiveJob** *of type `address`*

--- 
### Transfer(address,address,uint256)


**Execution cost**: No bound available


Params:

1. **from** *of type `address`*
2. **to** *of type `address`*
3. **value** *of type `uint256`*

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
### decreaseApproval(address,uint256)


**Execution cost**: No bound available


Params:

1. **_spender** *of type `address`*
2. **_subtractedValue** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### name()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `string`*

--- 
### isActiveJob(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **job** *of type `address`*

Returns:


1. **output_0** *of type `bool`*

--- 
### createCognitiveJob(address,address,uint256,bytes32)


**Execution cost**: No bound available

**Attributes**: payable


Params:

1. **kernel** *of type `address`*
2. **dataset** *of type `address`*
3. **comlexity** *of type `uint256`*
4. **description** *of type `bytes32`*

Returns:


1. **output_0** *of type `address`*
2. **output_1** *of type `uint8`*

--- 
### finishCognitiveJob()


**Execution cost**: No bound available




--- 
### allowance(address,address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_owner** *of type `address`*
2. **_spender** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### increaseApproval(address,uint256)


**Execution cost**: No bound available


Params:

1. **_spender** *of type `address`*
2. **_addedValue** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### cognitiveJobs(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### INITIAL_SUPPLY()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### decimals()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### cognitiveJobFactory()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### jobAddresses(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### destroyWorkerNode(address)


**Execution cost**: No bound available


Params:

1. **node** *of type `address`*


--- 
### approve(address,uint256)


**Execution cost**: No bound available


Params:

1. **_spender** *of type `address`*
2. **_value** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### balanceOf(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **_owner** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### createWorkerNode()


**Execution cost**: No bound available



Returns:


1. **output_0** *of type `address`*

--- 
### cognitiveJobsCount()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### penaltizeWorkerNode(address,uint8)


**Execution cost**: No bound available


Params:

1. **guilty** *of type `address`*
2. **reason** *of type `uint8`*


--- 
### symbol()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `string`*

--- 
### totalSupply()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### transfer(address,uint256)


**Execution cost**: No bound available


Params:

1. **_to** *of type `address`*
2. **_value** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### transferFrom(address,address,uint256)


**Execution cost**: No bound available


Params:

1. **_from** *of type `address`*
2. **_to** *of type `address`*
3. **_value** *of type `uint256`*

Returns:


1. **output_0** *of type `bool`*

--- 
### workerAddresses(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

--- 
### workerNodeFactory()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### workerNodes(uint256)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### workerNodesCount()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

[Back to the top ↑](#ipandora)
