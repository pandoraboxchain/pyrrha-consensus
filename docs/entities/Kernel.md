# Kernel


**Execution cost**: No bound available

**Deployment cost**: less than 211600 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_ipfsAddress** *of type `bytes`*
2. **_dataDim** *of type `uint256`*
3. **_complexity** *of type `uint256`*
4. **_initialPrice** *of type `uint256`*

## Events
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*

--- 
### PriceUpdated(uint256,uint256)


**Execution cost**: No bound available


Params:

1. **oldPrice** *of type `uint256`*
2. **newPrice** *of type `uint256`*


## Methods
### complexity()


**Execution cost**: less than 384 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### currentPrice()


**Execution cost**: less than 472 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### dataDim()


**Execution cost**: less than 494 gas

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
### owner()


**Execution cost**: less than 603 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 22897 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### updatePrice(uint256)


**Execution cost**: less than 22056 gas


Params:

1. **_newPrice** *of type `uint256`*


--- 
### withdrawBalance()
>
>Withdraws full balance to the owner account. Can be called only by the owner of the contract.


**Execution cost**: No bound available




[Back to the top ↑](#kernel)
