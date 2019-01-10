# Economic related notes  
Notes, changes and economic model description. 

### PAN token contract  

- The token contract is deployed as a separate contract. Link to the Pan contract is stored in the EconomicController contract for direct tokens management purposes. See `EconomicController` constructor.    

### Economic Controller  

- All functions dedicated to economic managemnt are placed in the `EconomicController` contract.  
- `EconomicController` is using `LedgersLib` library for managment of funds (block, unblock tokens). 
- `EconomicController` used for making rewards and applying of penalties. Related methods calls are doing from the `CognitiveJobManager` and `CognitiveJobController` contracts.

### Worker node   

- Node owner should have a minimum value of PAN tokens on a balance
- A required minimum value of tokens for the stake is a constant in the `TokensManager` contract  
- Worker node owner should provide a `computingPrice` value during node creation. 
This value should not be less then 1. See `createWorkerNode` method in the `WorkerNodeManager` contract.

### Job creation

- A job creator before the job creation should approve (`pan.approve` function) the required amount of Pan tokens to the `EconomicController` address. Required amount can be calculated as a summa of the following parts:    
  - `Dataset.currentPrice`
  - `Kernel.currentPrice` 
  - `Pandora.getMaximumWorkerPrice` * `batchesCount`
- After job is compleated the difference between (`Pandora.getMaximumWorkerPrice` * `batchesCount`) and (Sum of `actualWorkerNodeCoputingPrice` * `batchesCount`) is refunded to the job creator

### Dealing with the assigned job  

- Each time `WorkerNode` submitting updates related to the assigned job 
(methods: `acceptAssignment`, `declineAssignment`, `acceptValidData`, `declineValidData`) 
`CognitiveJobManager` doing validation of a node stake. 
In case of this stake will be equal to zero then node calls **will be rejected**.

### Penalties  

- If a worker node staying in the `Offline` state during node selection procedure this node will be penalized in the amount of its `computingPrice` (`OfflineWhileGathering` penalty)   
- If a worker node assigned to a job rejects assignment (called `declineAssignment` method) this node will be penalized in the amount of its `computingPrice` (`DeclinesJob` penalty)  
- *`OfflineWhileDataValidation` penalty not implemented yet*  
- If a worker node will provide results and these results will be classified as invalid data this node will be penalized in the amount of whole node stake (`FalseReportInvalidData` penalty). In the actual contracts version, this kind of penalty is ignored due to a lack of validation features.  
- If a worker node does not provide any progress of results during 30 min from the last transaction this node is classified as `Offline` node and will be penalized in the amount of its `computingPrice` (`OfflineWhileCognition` penalty)

*Notice*: penalized worker node is automatically transitting to the `UnderPenalty` state. Penalized nodes are not participating in nodes lottery. In order for the node to again have the opportunity to participate in the lottery, it must be transferred to the `Idle` state.

### Rewards  

- All active parties (all except for the job creator) of the job are obtaining rewards with system commission applied. System commission is defined in the `EconomicController` contract (defined in percentages). 
- Dataset owner obtaining reward in the amount of `Dataset.currentPrice` - system commission  
- Kernel owner obtaining reward in the amount of `Kernel.currentPrice` - system commission  
- Each worker node owner obtaining a reward in the amount of a maximum worker node computing price (`pandora.getMaximumWorkerPrice`). Difference between maximum and actual worker node computing price (tokens) is minting during the rewarding process. This `miniting` process is named `Mining`. System is obtaining its part of mined tokens in the amount of defined percentages.

*Notice*: tokens obtained by the system as system commission can be withdrawn by Pandora owner using `pandora.withdrawSystemTokens` function. 

