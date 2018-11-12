# PAN
> PAN Token Contract (Pandora Artificial Neuronetwork Token) for Pyrrha cognitive network
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: No bound available

**Deployment cost**: less than 360000 gas

**Combined cost**: No bound available

## Constructor




## Events
### Transfer(address,address,uint256)


**Execution cost**: No bound available


Params:

1. **from** *of type `address`*
2. **to** *of type `address`*
3. **value** *of type `uint256`*

--- 
### Approval(address,address,uint256)


**Execution cost**: No bound available


Params:

1. **owner** *of type `address`*
2. **spender** *of type `address`*
3. **value** *of type `uint256`*


## Methods
### name()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `string`*

--- 
### approve(address,uint256)
>
> Approve the passed address to spend the specified amount of tokens on behalf of msg.sender. Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729


**Execution cost**: less than 22458 gas


Params:

1. **spender** *of type `address`*

    > The address which will spend the funds.

2. **value** *of type `uint256`*

    > The amount of tokens to be spent.


Returns:


1. **output_0** *of type `bool`*

--- 
### totalSupply()
>
> Total number of tokens in existence


**Execution cost**: less than 428 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### transferFrom(address,address,uint256)
>
> Transfer tokens from one address to another


**Execution cost**: No bound available


Params:

1. **from** *of type `address`*

    > address The address which you want to send tokens from

2. **to** *of type `address`*

    > address The address which you want to transfer to

3. **value** *of type `uint256`*

    > uint256 the amount of tokens to be transferred


Returns:


1. **output_0** *of type `bool`*

--- 
### INITIAL_SUPPLY()


**Execution cost**: less than 272 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### decimals()


**Execution cost**: less than 294 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### increaseAllowance(address,uint256)
>
> Increase the amount of tokens that an owner allowed to a spender. approve should be called when allowed_[_spender] == 0. To increment allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol


**Execution cost**: No bound available


Params:

1. **spender** *of type `address`*

    > The address which will spend the funds.

2. **addedValue** *of type `uint256`*

    > The amount of tokens to increase the allowance by.


Returns:


1. **output_0** *of type `bool`*

--- 
### balanceOf(address)
>
> Gets the balance of the specified address.


**Execution cost**: less than 763 gas

**Attributes**: constant


Params:

1. **owner** *of type `address`*

    > The address to query the balance of.


Returns:

> An uint256 representing the amount owned by the passed address.

1. **output_0** *of type `uint256`*

--- 
### symbol()


**Execution cost**: No bound available

**Attributes**: constant



Returns:


1. **output_0** *of type `string`*

--- 
### decreaseAllowance(address,uint256)
>
> Decrease the amount of tokens that an owner allowed to a spender. approve should be called when allowed_[_spender] == 0. To decrement allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol


**Execution cost**: No bound available


Params:

1. **spender** *of type `address`*

    > The address which will spend the funds.

2. **subtractedValue** *of type `uint256`*

    > The amount of tokens to decrease the allowance by.


Returns:


1. **output_0** *of type `bool`*

--- 
### transfer(address,uint256)
>
> Transfer token for a specified address


**Execution cost**: No bound available


Params:

1. **to** *of type `address`*

    > The address to transfer to.

2. **value** *of type `uint256`*

    > The amount to be transferred.


Returns:


1. **output_0** *of type `bool`*

--- 
### allowance(address,address)
>
> Function to check the amount of tokens that an owner allowed to a spender.


**Execution cost**: less than 950 gas

**Attributes**: constant


Params:

1. **owner** *of type `address`*

    > address The address which owns the funds.

2. **spender** *of type `address`*

    > address The address which will spend the funds.


Returns:

> A uint256 specifying the amount of tokens still available for the spender.

1. **output_0** *of type `uint256`*

[Back to the top ↑](#pan)
