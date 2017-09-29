pragma solidity ^0.4.15;


library CallOnce {
    struct OnceFlags {
        mapping(string => bool) flags;
    }

    modifier onlyOnce(OnceFlags storage _onceFlags, string _flagName) {
        require(_onceFlags.flags[_flagName] == false);
        _;
        _onceFlags.flags[_flagName] = true;
    }
}
