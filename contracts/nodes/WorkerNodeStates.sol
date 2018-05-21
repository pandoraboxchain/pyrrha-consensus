pragma solidity ^0.4.23;


contract WorkerNodeStates {
    /// @dev Since `destroyself()` zeroes values of all variables, we need the first state (corresponding to zero)
    /// to indicate that contract had being destroyed
    uint8 public constant Destroyed = 0xFF;

    /// @dev Reserved system state not participating in transition table. Since contract creation all variables are
    /// initialized to zero and contract state will be zero until it will be initialized with some definite state
    uint8 public constant Uninitialized = 0;

    /// @dev When node goes offline it can mark itself as offline to prevent penalties.
    /// If node is not responding to Pandora events and does not submit updates on the cognitive work in time
    /// then it will be penaltied and put into `Offline` state
    uint8 public constant Offline = 1;

    /// @dev Initial and base state
    uint8 public constant Idle = 2;

    /// @dev State when cognitive job is created and worker node is assigned to it, but the node didn't responded with
    /// readiness status yet
    uint8 public constant Assigned = 3;

    /// @dev Worker node have responded with readiness status and awaits cognitive job contract to transition into the
    /// next stage
    uint8 public constant ReadyForDataValidation = 4;

    /// @dev Worker node downloads and validates source data for correctness and consistency
    uint8 public constant ValidatingData = 5;

    /// @dev Worker node have finished data validation, confirmed data correctness and completeness, and reported
    /// readiness to start performing actual cognition – however cognitive job contract didn't transitioned into
    /// cognitive state yet (not all workers have reported readiness)
    uint8 public constant ReadyForComputing = 6;

    /// @dev State when worker node performs cognitive job
    uint8 public constant Computing = 7;

    /// @dev Intermediary state when worker node stake is reduced below threshold required for performing
    /// cognitive computations
    uint8 public constant InsufficientStake = 8;

    /// @dev Intermediary state preventing from performing any type of work during penalty process
    uint8 public constant UnderPenalty = 9;
}
