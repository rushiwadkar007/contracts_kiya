// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMultiSigFactory {
    function emitOwners(
        address _contractAddress,
        address[] memory _owners,
        uint256 _signaturesRequired
    ) external;

    function create(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _signaturesRequired,
        string memory orgName,
        string memory orgEmail
    ) external payable;

    function numberOfMultiSigs() external view returns (uint256);

    function getMultiSig(uint256 _index)
        external
        view
        returns (
            address multiSigAddress,
            uint256 signaturesRequired,
            uint256 balance,
            string memory organizationName,
            string memory organizationEmail
        );
}
