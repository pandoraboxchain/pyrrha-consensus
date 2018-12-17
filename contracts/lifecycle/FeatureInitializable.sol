pragma solidity 0.4.24;


/**
 * @title FeatureInitializable
 * @dev The FeatureInitializable contract provides initialization control for separate features
 */
contract FeatureInitializable {

    mapping(bytes32 => bool) initialized;// feature key => isInitialized

    /**
     * @dev This event will be emitted if feature is set initialized
     * @param initializer Feature initializer
     */
    event FeatureInitialized(bytes32 indexed feature, address indexed initializer);

    /**
     * @dev Throws if called not initialized contract
     * @param feature Feature name
     */
    modifier onlyInitializedFeature(bytes32 feature) {
        require(isFeatureInitialized(feature), "ERROR_FEATURE_NOT_INITIALIZED");
        _;
    }

    /**
     * @dev Throws if called already initialized contract
     * @param feature Feature name
     */
    modifier notInitializedFeature(bytes32 feature) {
        require(!isFeatureInitialized(feature), "ERROR_FEATURE_ALREADY_INITIALIZED");
        _;
    }

    /**
     * @dev Returns is the contract is initialized
     * @param feature Feature name
     * @return bool value of initialized state
     */
    function isFeatureInitialized(bytes32 feature) public view returns(bool) {
        return initialized[feature];
    }

    /**
     * @dev Set the feature as initialized and emit a proper event
     * @param feature Feature name
     */
    function _setFeatureInitialized(bytes32 feature) internal {
        require(!isFeatureInitialized(feature), "ERROR_ALREADY_INITIALIZED");
        initialized[feature] = true;
        emit FeatureInitialized(feature, msg.sender);
    }
}
