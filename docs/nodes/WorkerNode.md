# WorkerNode
> Worker Node Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: No bound available

**Deployment cost**: less than 921000 gas

**Combined cost**: No bound available

## Constructor



Params:

1. **_pandora** *of type `address`*

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
### StateChanged(uint8,uint8)


**Execution cost**: No bound available


Params:

1. **oldState** *of type `uint8`*
2. **newState** *of type `uint8`*

--- 
### WorkerDestroyed()


**Execution cost**: No bound available




## Methods
### Offline()


**Execution cost**: less than 523 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

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


**Execution cost**: less than 809 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientStake()


**Execution cost**: less than 787 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### acceptValidData()


**Execution cost**: No bound available




--- 
### acceptAssignment()


**Execution cost**: No bound available




--- 
### Destroyed()


**Execution cost**: less than 743 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### ValidatingData()


**Execution cost**: less than 457 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### alive()
>
>### External and public functions


**Execution cost**: No bound available




--- 
### ReadyForDataValidation()


**Execution cost**: less than 721 gas

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
### destroy()


**Execution cost**: less than 32114 gas




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


**Execution cost**: less than 933 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### activeJob()


**Execution cost**: less than 955 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### UnderPenalty()


**Execution cost**: less than 633 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### Idle()


**Execution cost**: less than 655 gas

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
### processToDataValidation()


**Execution cost**: No bound available




--- 
### provideResults(bytes)


**Execution cost**: No bound available


Params:

1. **_ipfsAddress** *of type `bytes`*


--- 
### renounceOwnership()
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22314 gas




--- 
### reportInvalidData()


**Execution cost**: No bound available




--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23398 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### withdrawBalance()
>
>Withdraws full balance to the owner account. Can be called only by the owner of the contract.


**Execution cost**: No bound available




[Back to the top ↑](#workernode)
