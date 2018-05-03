# WorkerNodeManager
> Pandora Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: less than 61605 gas

**Deployment cost**: less than 511000 gas

**Combined cost**: less than 572605 gas

## Constructor



Params:

1. **_nodeFactory** *of type `address`*

## Events
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


**Execution cost**: less than 20571 gas




--- 
### workerAddresses(address)


**Execution cost**: less than 895 gas

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
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23081 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### penaltizeWorkerNode(address,uint8)


**Execution cost**: less than 613 gas


Params:

1. **_guiltyWorker** *of type `address`*
2. **_reason** *of type `uint8`*


--- 
### destroyWorkerNode(address)
>
>Removes worker from the workers list and destroys it. Can be called only by the worker node owner and only for the idle workers


**Execution cost**: No bound available


Params:

1. **_workerNode** *of type `address`*


--- 
### blacklistWorkerOwner(address)
>
>Removes address from the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 21085 gas


Params:

1. **_workerOwner** *of type `address`*


--- 
### whitelistWorkerOwner(address)
>
>### Public and externalAdds address to the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 20981 gas


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


**Execution cost**: less than 809 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### workerNodeFactory()


**Execution cost**: less than 864 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### workerNodeOwners(address)


**Execution cost**: less than 716 gas

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


**Execution cost**: less than 688 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

[Back to the top ↑](#workernodemanager)
