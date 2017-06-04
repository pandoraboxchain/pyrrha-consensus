pragma solidity ^0.4.8;

/*

 */

import './zeppelin/lifecycle/Destructible.sol';

contract HardwareContract is Destructible {
    string serviceURL;
    uint lowerPriceBoundary;

    function HardwareContract (string _serviceURL, uint _lowerPriceBoundary) {
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
