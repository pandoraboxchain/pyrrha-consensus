# Reputation


**Execution cost**: less than 20512 gas

**Deployment cost**: less than 149400 gas

**Combined cost**: less than 169912 gas

## Constructor




## Events
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*


## Methods
### decrReputation(address,uint256)


**Execution cost**: less than 21355 gas


Params:

1. **account** *of type `address`*
2. **amount** *of type `uint256`*


--- 
### incrReputation(address,uint256)


**Execution cost**: less than 1026 gas


Params:

1. **account** *of type `address`*
2. **amount** *of type `uint256`*


--- 
### owner()


**Execution cost**: less than 559 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 22797 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### values(address)


**Execution cost**: less than 531 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

[Back to the top ↑](#reputation)
