# Reputation


**Execution cost**: less than 22105 gas

**Deployment cost**: less than 193600 gas

**Combined cost**: less than 215705 gas


## Events
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*


## Methods
### values(address)


**Execution cost**: less than 531 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### renounceOwnership()
>
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22508 gas




--- 
### owner()


**Execution cost**: less than 581 gas

**Attributes**: constant



Returns:

> the address of the owner.

1. **output_0** *of type `address`*

--- 
### isOwner()


**Execution cost**: less than 536 gas

**Attributes**: constant



Returns:

> true if `msg.sender` is the owner of the contract.

1. **output_0** *of type `bool`*

--- 
### incrReputation(address,uint256)


**Execution cost**: less than 21376 gas


Params:

1. **account** *of type `address`*
2. **amount** *of type `uint256`*


--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 22903 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### decrReputation(address,uint256)


**Execution cost**: less than 21432 gas


Params:

1. **account** *of type `address`*
2. **amount** *of type `uint256`*


[Back to the top ↑](#reputation)
