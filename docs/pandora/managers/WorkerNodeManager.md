# WorkerNodeManager


**Execution cost**: No bound available

**Deployment cost**: No bound available

**Combined cost**: No bound available

## Constructor



Params:

1. **_nodeFactory** *of type `address`*

## Events
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
### penaltizeWorkerNode(address,uint8)


**Execution cost**: No bound available


Params:

1. **guilty** *of type `address`*
2. **reason** *of type `uint8`*


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
### initialize()


**Execution cost**: No bound available




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
### destroyWorkerNode(address)


**Execution cost**: No bound available


Params:

1. **_workerNode** *of type `address`*


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
### workerAddresses(address)


**Execution cost**: No bound available

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint16`*

[Back to the top ↑](#workernodemanager)
