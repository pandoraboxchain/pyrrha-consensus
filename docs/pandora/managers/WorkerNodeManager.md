# WorkerNodeManager
> Pandora Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: less than 61619 gas

**Deployment cost**: less than 547000 gas

**Combined cost**: less than 608619 gas

## Constructor



Params:

1. **_nodeFactory** *of type `address`*

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
### blacklistWorkerOwner(address)
>
>Removes address from the whitelist of owners allowed to create WorkerNodes contracts
>
> Can be called only by the owner of Pandora contract


**Execution cost**: less than 21095 gas


Params:

1. **_workerOwner** *of type `address`*


--- 
### workerAddresses(address)


**Execution cost**: less than 917 gas

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


**Execution cost**: less than 23120 gas


Params:

1. **_newOwner** *of type `address`*

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
### renounceOwnership()
>
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22286 gas




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
### initialize()


**Execution cost**: less than 20593 gas




--- 
### createWorkerNode()
>
>Creates, registers and returns a new worker node owned by the caller of the contract. Can be called only by the whitelisted node owner address.


**Execution cost**: No bound available



Returns:


1. **output_0** *of type `address`*

--- 
### owner()


**Execution cost**: less than 831 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### workerNodeFactory()


**Execution cost**: less than 886 gas

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
