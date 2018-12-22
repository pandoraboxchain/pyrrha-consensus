# Economic related notes  
Notes, changes and economic model description. 

## Workflows

### New worker node registration  

- Node owner should have a minimum value of PAN tokens on a balance
- A required minimum value of tokens for the stake is a constant in the `TokensManager` contract that equals to 100 PAN  
- Worker node owner should provide a minimum `computingPrice` value during node creation. 
This value should not be less then 1. See `createWorkerNode` method in the `WorkerNodeManager` contract.


### Dealing with the assigned job  

- Each time `WorkerNode` submitting updated related to the assigned job 
(methods: `acceptAssignment`, `declineAssignment`, `acceptValidData`, `declineValidData`) 
`CognitiveJobManager` doing validation of a node stake. 
In case of this stake will be equal to zero then node calls **will be rejected**.

