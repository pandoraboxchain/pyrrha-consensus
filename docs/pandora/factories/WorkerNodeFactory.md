# WorkerNodeFactory


**Execution cost**: less than 23266 gas

**Deployment cost**: less than 1309000 gas

**Combined cost**: less than 1332266 gas

## Constructor




## Events
### WorkerNodeOwner(address)


**Execution cost**: No bound available


Params:

1. **owner** *of type `address`*

--- 
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*


## Methods
### renounceOwnership()
>
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22486 gas




--- 
### owner()


**Execution cost**: less than 559 gas

**Attributes**: constant



Returns:

> the address of the owner.

1. **output_0** *of type `address`*

--- 
### isOwner()


**Execution cost**: less than 514 gas

**Attributes**: constant



Returns:

> true if `msg.sender` is the owner of the contract.

1. **output_0** *of type `bool`*

--- 
### create(address)
>
> Creates worker node contract for the main Pandora contract and does necessary preparations of it (transferring ownership). Can be called only by a Pandora contract (Pandora is the owner of the factory)


**Execution cost**: No bound available


Params:

1. **_nodeOwner** *of type `address`*

Returns:


1. **o_workerNode** *of type `address`*

--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 22881 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



[Back to the top ↑](#workernodefactory)
