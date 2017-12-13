pragma solidity ^0.4.18;


contract Initializable {
    bool public initialized = false;

    function Initializable() public {
        initialized = false;
    }

    function initialize() public {
        initialized = true;
    }

    /// @dev Modifier ensures that the function can be called only after Pandora contract was properly initialized
    /// (see `initialize` and `properlyInitialized`
    modifier onlyInitialized() {
        require(initialized == true);
        _;
    }
}
