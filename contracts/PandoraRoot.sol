pragma solidity ^0.5.0;

import './zeppelin/token/ERC20Basic.sol';
import "./PandoraProtocolIf.sol";

contract PandoraRoot is BasicToken {

    /*
     * Non-changing part of ERC20 implementation
     */
    string public constant name = "Pandora";
    string public constant symbol = "PAN";
    uint public constant decimals = 18;

    PandoraProtocolIf activeProtocol;
    PandoraProtocolIf[] pastProtocols;

    function PandoraRoot(PandoraProtocolIf _initialProtocol) {
        // We require to instantiate the root contract only with some initial consensus protocol implementation
        require(_initialProtocol != 0);

        upgradingProtocol = true;
        // Assigning active consensus protocol implementation from the function argument
        activeProtocol = _initialProtocol;
        upgradingProtocol = false;
    }

    /*
     * Receiving Ether by the root contract: delegate behaviour implementation to the current protocol
     */
    function() payable {
        activeProtocol.transfer(msg.value);
    }

    /***
     * Protocol management functions
     */

    event ProtocolChanged();

    bool internal upgradingProtocol = true;

    modifier onlyActiveProtocol() {
        require(msg.sender == activeProtocol);
        _;
    }

    modifier hasActiveProtocol() {
        require(upgradingProtocol == false);
        _;
    }

    function isProtocolCorrect(PandoraProtocolIf _someAddress) pure returns (bool) {
        return _someAddress.rootbox == this;
    }

    function upgradeProtocol(PandoraProtocolIf _newProtocol) external onlyActiveProtocol hasActiveProtocol {
        require(_initialProtocol != 0);
        require(isProtocolCorrect(_newProtocol));

        upgradingProtocol = true;
        pastProtocols.push(activeProtocol);
        activeProtocol = _newProtocol;
        upgradingProtocol = false;
    }

    function downgradeProtocol(unit32 _downgradeDepth) external onlyActiveProtocol hasActiveProtocol {
        require(_downgradeDepth >= 1);
        require(_downgradeDepth <= pastProtocols.length);

        upgradingProtocol = true;
        uint32 offset = pastProtocols.length - _downgradeDepth;
        assert(offset > 0 && offset < pastProtocols.length);
        protocol = pastProtocols[offset];
        assert(isProtocolCorrect(protocol));
        PandoraProtocolIf[] protocolStack = new PandoraProtocolIf[](offset);
        for (uint32 no = 0; no < offset; no++) {
            protocolStack[no] = pastProtocols[no];
        }
        pastProtocols = protocolStack;
        activeProtocol = protocol;
        upgradingProtocol = false;
    }

    function changeBalance(address _addr, uint256 _newBalance) external onlyActiveProtocol hasActiveProtocol {

    }
}
