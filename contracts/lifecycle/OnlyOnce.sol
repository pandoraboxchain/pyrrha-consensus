pragma solidity ^0.4.23;


contract OnlyOnce {

    constructor() public { }

    /// @dev Internal private mapping storing flags indicating which of `onlyOnce` functions was already called.
    mapping(string => bool) private onceFlags;
    /// @dev Ensures that function with the modifier can be called only once during the whole contract lifecycle
    modifier onlyOnce(
        string _id /// Some id used to uniquely identify the caller function (usually the function name as a string)
    ) {
        require(onceFlags[_id] == false);
        _;
        onceFlags[_id] = true;
    }
}
