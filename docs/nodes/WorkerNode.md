# WorkerNode
> Worker Node Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: No bound available

**Deployment cost**: less than 1209000 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_pandora** *of type `address`*

## Events
### OwnershipTransferred(address,address)


**Execution cost**: No bound available


Params:

1. **previousOwner** *of type `address`*
2. **newOwner** *of type `address`*

--- 
### StateChanged(uint8,uint8)


**Execution cost**: No bound available


Params:

1. **oldState** *of type `uint8`*
2. **newState** *of type `uint8`*

--- 
### WorkerDestroyed()


**Execution cost**: No bound available




## Methods
### destroy()


**Execution cost**: less than 32136 gas




--- 
### processToCognition()


**Execution cost**: No bound available




--- 
### pandora()


**Execution cost**: less than 581 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### declineValidData()


**Execution cost**: No bound available




--- 
### Uninitialized()


**Execution cost**: less than 281 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Computing()


**Execution cost**: less than 303 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### ReadyForComputing()


**Execution cost**: less than 325 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Assigned()


**Execution cost**: less than 919 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientStake()


**Execution cost**: less than 897 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### maxPenalty()


**Execution cost**: No bound available




--- 
### increaseReputation()


**Execution cost**: less than 21622 gas




--- 
### acceptValidData()


**Execution cost**: No bound available




--- 
### acceptAssignment()


**Execution cost**: No bound available




--- 
### ValidatingData()


**Execution cost**: less than 479 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### alive()
>
>### External and public functions


**Execution cost**: No bound available




--- 
### Destroyed()


**Execution cost**: less than 831 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Offline()


**Execution cost**: less than 545 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### currentState()
>
>Returns current state of the contract state machine
>
> Shortcut to receive current state from external contracts


**Execution cost**: less than 432 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### assignJob(address)
>
>Do not call
>
> Assigns cognitive job to the worker. Can be called only by one of active cognitive jobs listed under the main Pandora contract


**Execution cost**: No bound available


Params:

1. **_job** *of type `address`*


--- 
### owner()


**Execution cost**: less than 955 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### activeJob()


**Execution cost**: less than 977 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### UnderPenalty()


**Execution cost**: less than 655 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### deathPenalty()
>
>For internal use by main Pandora contract
>
> Zeroes reputation and destroys node


**Execution cost**: No bound available




--- 
### decreaseReputation()


**Execution cost**: No bound available




--- 
### Idle()


**Execution cost**: less than 721 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### cancelJob()


**Execution cost**: No bound available




--- 
### declineAssignment()


**Execution cost**: No bound available




--- 
### ReadyForDataValidation()


**Execution cost**: less than 809 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### processToDataValidation()


**Execution cost**: No bound available




--- 
### provideResults(bytes)


**Execution cost**: No bound available


Params:

1. **_ipfsAddress** *of type `bytes`*


--- 
### reportInvalidData()


**Execution cost**: No bound available




--- 
### reputation()


**Execution cost**: less than 978 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### resetReputation()


**Execution cost**: No bound available




--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23479 gas


Params:

1. **newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### withdrawBalance()
>
>Withdraws full balance to the owner account. Can be called only by the owner of the contract.


**Execution cost**: No bound available




[Back to the top ↑](#workernode)
