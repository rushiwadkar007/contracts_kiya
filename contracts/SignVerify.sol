// SPDX-License-Identifier: GPL-3.0
/**
 *Submitted for verification at Etherscan.io on 2017-11-28
 */
pragma solidity ^0.8.0;

contract Verse {
    function getMessageHash(string memory _passkey)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_passkey));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        internal
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verifyUserSign(
        address user,
        string memory _passkey,
        bytes memory signature
    ) external pure returns (bool isUserVerified, address userWalletAddress) {
        bytes32 messageHash = getMessageHash(_passkey);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return (recoverSigner(ethSignedMessageHash, signature) == user, recoverSigner(ethSignedMessageHash, signature));
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}