# WorkerNodeFactory


**Execution cost**: less than 22014 gas

**Deployment cost**: less than 1640200 gas

**Combined cost**: less than 1662214 gas

## Constructor




## Events
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


**Execution cost**: less than 537 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 22775 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



[Back to the top ↑](#workernodefactory)
