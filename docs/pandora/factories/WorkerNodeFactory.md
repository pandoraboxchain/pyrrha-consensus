# WorkerNodeFactory


**Execution cost**: less than 21621 gas

**Deployment cost**: less than 1280000 gas

**Combined cost**: less than 1301621 gas

## Constructor




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
### WorkerNodeOwner(address)


**Execution cost**: No bound available


Params:

1. **owner** *of type `address`*


## Methods
### create(address)
>
> Creates worker node contract for the main Pandora contract and does necessary preparations of it (transferring ownership). Can be called only by a Pandora contract (Pandora is the owner of the factory)


**Execution cost**: No bound available


Params:

1. **_nodeOwner** *of type `address`*

Returns:


1. **o_workerNode** *of type `address`*

--- 
### owner()


**Execution cost**: less than 559 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### renounceOwnership()
>
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22072 gas




--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 22826 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



[Back to the top ↑](#workernodefactory)
