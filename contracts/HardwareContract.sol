pragma solidity ^0.4.8;

/*

 */

import './zeppelin/lifecycle/Destructible.sol';

contract HardwareContract is Destructible {
    enum Type { GPU, TPU, Android }

    string serviceURL;
    uint lowerPriceBoundary;
    Type suppertedType;

    function HardwareContract (string _serviceURL, Type _supportedType, uint _lowerPriceBoundary) {
        suppertedType = _supportedType;
        serviceURL = _serviceURL;
        lowerPriceBoundary = _lowerPriceBoundary;
    }

    /*
    function updateURL (string newServiceURL) external returns (oldServiceURL) {
        oldServiceURL = serviceURL;
        serviceURL = newServiceURL;
    }

    function updateLowerPriceBoundary (string newPriceBoundary) external returns (oldPriceBoundary) {
        oldPriceBoundary = lowerPriceBoundary;
        lowerPriceBoundary = newPriceBoundary;
    }
    */
}
