# Dataset


**Execution cost**: No bound available

**Deployment cost**: less than 273000 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_ipfsAddress** *of type `bytes`*
2. **_dataDim** *of type `uint256`*
3. **_batchesCount** *of type `uint8`*
4. **_initialPrice** *of type `uint256`*
5. **_metadata** *of type `bytes32`*
6. **_description** *of type `bytes32`*

## Events
### PriceUpdated(uint256,uint256)


**Execution cost**: No bound available


Params:

1. **oldPrice** *of type `uint256`*
2. **newPrice** *of type `uint256`*

--- 
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*


## Methods
### metadata()


**Execution cost**: less than 384 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### withdrawBalance()
>
>Withdraws full balance to the owner account. Can be called only by the owner of the contract.


**Execution cost**: No bound available




--- 
### renounceOwnership()
>
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22530 gas




--- 
### description()


**Execution cost**: less than 450 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### batchesCount()


**Execution cost**: less than 498 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### updatePrice(uint256)


**Execution cost**: less than 22143 gas


Params:

1. **_newPrice** *of type `uint256`*


--- 
### owner()


**Execution cost**: less than 669 gas

**Attributes**: constant



Returns:

> the address of the owner.

1. **output_0** *of type `address`*

--- 
### isOwner()


**Execution cost**: less than 624 gas

**Attributes**: constant



Returns:

> true if `msg.sender` is the owner of the contract.

1. **output_0** *of type `bool`*

--- 
### currentPrice()


**Execution cost**: less than 560 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### dataDim()


**Execution cost**: less than 582 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### ipfsAddress()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes`*

--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23035 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



[Back to the top ↑](#dataset)
