# CognitiveJobFactory


**Execution cost**: less than 22682 gas

**Deployment cost**: less than 2234200 gas

**Combined cost**: less than 2256882 gas

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


## Methods
### create(address,address,address[],uint256,bytes32)


**Execution cost**: No bound available


Params:

1. **_kernel** *of type `address`*
2. **_dataset** *of type `address`*
3. **_workersPool** *of type `address[]`*
4. **_complexity** *of type `uint256`*
5. **_description** *of type `bytes32`*

Returns:


1. **o_cognitiveJob** *of type `address`*

--- 
### owner()


**Execution cost**: less than 581 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### renounceOwnership()
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22094 gas




--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 22826 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



[Back to the top ↑](#cognitivejobfactory)
