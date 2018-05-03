# PandoraMarket


**Execution cost**: less than 449 gas

**Deployment cost**: less than 410800 gas

**Combined cost**: less than 411249 gas

## Constructor




## Events
### DatasetAdded(address)


**Execution cost**: No bound available


Params:

1. **dataset** *of type `address`*

--- 
### DatasetRemoved(address)


**Execution cost**: No bound available


Params:

1. **dataset** *of type `address`*

--- 
### KernelAdded(address)


**Execution cost**: No bound available


Params:

1. **kernel** *of type `address`*

--- 
### KernelRemoved(address)


**Execution cost**: No bound available


Params:

1. **kernel** *of type `address`*


## Methods
### STATUS_SUCCESS()


**Execution cost**: less than 347 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### STATUS_FAILED_CONTRACT()


**Execution cost**: less than 193 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### STATUS_ALREADY_EXISTS()


**Execution cost**: less than 259 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### addDataset(address)


**Execution cost**: less than 62945 gas


Params:

1. **_dataset** *of type `address`*

Returns:


1. **o_result** *of type `uint8`*

--- 
### datasetMap(address)


**Execution cost**: less than 839 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### STATUS_NOT_EXISTS()


**Execution cost**: less than 435 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### addKernel(address)


**Execution cost**: less than 62880 gas


Params:

1. **_kernel** *of type `address`*

Returns:


1. **o_result** *of type `uint8`*

--- 
### STATUS_NO_SPACE()


**Execution cost**: less than 369 gas

**Attributes**: constant



Returns:


1. **output_0** *of type `uint8`*

--- 
### datasets(uint256)


**Execution cost**: less than 881 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### datasetsCount()


**Execution cost**: less than 494 gas

**Attributes**: constant



Returns:


1. **o_count** *of type `uint256`*

--- 
### kernelMap(address)


**Execution cost**: less than 751 gas

**Attributes**: constant


Params:

1. **param_0** *of type `address`*

Returns:


1. **output_0** *of type `uint256`*

--- 
### kernels(uint256)


**Execution cost**: less than 1101 gas

**Attributes**: constant


Params:

1. **param_0** *of type `uint256`*

Returns:


1. **output_0** *of type `address`*

--- 
### kernelsCount()


**Execution cost**: less than 472 gas

**Attributes**: constant



Returns:


1. **o_count** *of type `uint256`*

--- 
### removeDataset(address)


**Execution cost**: No bound available


Params:

1. **_dataset** *of type `address`*

Returns:


1. **o_result** *of type `uint8`*

--- 
### removeKernel(address)


**Execution cost**: No bound available


Params:

1. **_kernel** *of type `address`*

Returns:


1. **o_result** *of type `uint8`*

[Back to the top ↑](#pandoramarket)
