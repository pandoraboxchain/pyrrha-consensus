# StateMachine


**Execution cost**: less than 87 gas

**Deployment cost**: less than 63800 gas

**Combined cost**: less than 63887 gas


## Events
### StateChanged(uint8,uint8)


**Execution cost**: No bound available


Params:

1. **oldState** *of type `uint8`*
2. **newState** *of type `uint8`*


## Methods
### currentState()
>
>Returns current state of the contract state machine
>
> Shortcut to receive current state from external contracts


**Execution cost**: less than 410 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### transitionToState(uint8)
>
> State transition function


**Execution cost**: less than 21825 gas


Params:

1. **_newState** *of type `uint8`*


[Back to the top ↑](#statemachine)
