# CognitiveJobLib


**Execution cost**: less than 116 gas

**Deployment cost**: less than 15200 gas

**Combined cost**: less than 15316 gas


## Events
### CognitionCompleted(bytes32,bool)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*
2. **partialResult** *of type `bool`*

--- 
### CognitionProgressed(bytes32,uint8)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*
2. **precent** *of type `uint8`*

--- 
### CognitionStarted(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### DataValidationFailed(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### DataValidationStarted(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### JobStateChanged(bytes32,uint8,uint8)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*
2. **oldState** *of type `uint8`*
3. **newState** *of type `uint8`*

--- 
### WorkersNotFound(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*

--- 
### WorkersUpdated(bytes32)


**Execution cost**: No bound available


Params:

1. **jobId** *of type `bytes32`*



[Back to the top ↑](#cognitivejoblib)
