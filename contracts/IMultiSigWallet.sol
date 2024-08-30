// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMultiSigWallet {
    function addSigner(
        address owner,
        address newSigner,
        uint256 newSignaturesRequired
    ) external;

    function removeSigner(
        address owner,
        address oldSigner,
        uint256 newSignaturesRequired
    ) external;

    function executeApproval(
        address payable to,
        uint256 value,
        bytes memory signature,
        string memory passkey,
        string memory transactionStamp,
        uint256 trxNo
    ) external returns (bool, bytes memory);

    function getTransactionHash(
        uint256 _nonce,
        address to,
        uint256 value
    ) external view returns (bytes32);

    function recover(bytes32 _hash, bytes memory _signature)
        external
        pure
        returns (address);

    function totalTransactionValidations(uint256 trxNo)
        external
        view
        returns (uint256);

    function incrementNonce() external returns (uint256);
}
