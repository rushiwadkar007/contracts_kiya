// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

// Sources flattened with hardhat v2.14.0 https://hardhat.org

// File contracts/_testContracts/MockContract.sol

contract MockContract {
    address _irRegistry;
    uint16 _investorCountry;

    function identityRegistry() public view returns (address identityRegistry) {
        if (_irRegistry != address(0)) {
            return _irRegistry;
        } else {
            return address(this);
        }
    }

    function investorCountry(address investor) public view returns (uint16 country) {
        return _investorCountry;
    }

    function setInvestorCountry(uint16 country) public {
        _investorCountry = country;
    }
}
