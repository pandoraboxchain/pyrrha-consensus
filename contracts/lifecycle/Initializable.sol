pragma solidity ^0.4.18;


contract Initializable {
    bool public properlyInitialized = false;

    function Initializable () public {
        properlyInitialized = false;
    }

    function initialize () public {
        properlyInitialized = true;
    }

    /// @dev Modifier ensures that the function can be called only after Pandora contract was properly initialized
    /// (see `initialize` and `properlyInitialized`
    modifier onlyInitialized() {
        require(properlyInitialized == true);
        _;
    }
}
