# WorkerNode
> Worker Node Smart Contract
>
> Author: "Dr Maxim Orlovsky" <orlovsky@pandora.foundation>


**Execution cost**: No bound available

**Deployment cost**: less than 821800 gas

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
### assignJob(bytes32)
>
>Do not call
>
> Assigns cognitive job to the worker. Can be called only by one of active cognitive jobs listed under the main Pandora contract


**Execution cost**: No bound available


Params:

1. **_jobId** *of type `bytes32`*


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


**Execution cost**: less than 875 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### InsufficientStake()


**Execution cost**: less than 853 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### jobProgress()


**Execution cost**: less than 582 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint256`*

--- 
### acceptValidData()


**Execution cost**: No bound available




--- 
### acceptAssignment()


**Execution cost**: No bound available




--- 
### Destroyed()


**Execution cost**: less than 809 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### ValidatingData()


**Execution cost**: less than 479 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### alive()


**Execution cost**: No bound available




--- 
### ReadyForDataValidation()


**Execution cost**: less than 787 gas

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
### Offline()


**Execution cost**: less than 567 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### destroy()
>
>### External and public functions


**Execution cost**: less than 31860 gas




--- 
### owner()


**Execution cost**: less than 955 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `address`*

--- 
### activeJob()


**Execution cost**: less than 824 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `bytes32`*

--- 
### UnderPenalty()


**Execution cost**: less than 655 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### declineAssignment()


**Execution cost**: No bound available




--- 
### Idle()


**Execution cost**: less than 699 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### cancelJob()


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
>Renouncing to ownership will leave the contract without an owner. It will not be possible to call the functions with the `onlyOwner` modifier anymore.
>
> Allows the current owner to relinquish control of the contract.


**Execution cost**: less than 22336 gas




--- 
### reportInvalidData()


**Execution cost**: No bound available




--- 
### reportProgress(uint8)


**Execution cost**: No bound available


Params:

1. **_percent** *of type `uint8`*


--- 
### transferOwnership(address)
>
> Allows the current owner to transfer control of the contract to a newOwner.


**Execution cost**: less than 23464 gas


Params:

1. **_newOwner** *of type `address`*

    > The address to transfer ownership to.



--- 
### transitionToState(uint8)
>
> State transition function


**Execution cost**: less than 22287 gas


Params:

1. **_newState** *of type `uint8`*


--- 
### withdrawBalance()
>
>Withdraws full balance to the owner account. Can be called only by the owner of the contract.


**Execution cost**: No bound available




[Back to the top ↑](#workernode)
