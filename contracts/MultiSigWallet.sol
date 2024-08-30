// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// never forget the OG simple sig wallet: https://github.com/christianlundkvist/simple-multisig/blob/master/contracts/SimpleMultiSig.sol

pragma experimental ABIEncoderV2;
import "./ECDSA.sol";
import "./MultiSigFactory.sol";
import "./IMultiSigWallet.sol";

//ONLY FOR ADMIN LEVEL APPROVAL
contract MultiSigWallet is IMultiSigWallet {
    using ECDSA for bytes32;
    MultiSigFactory private multiSigFactory;
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event ExecuteTransaction(
        address indexed owner,
        address payable to,
        uint256 value,
        // bytes data,
        uint256 nonce,
        bytes32 hash
        // bytes result
    );
    event Owner(address indexed owner, bool added);
    event ExecuteApproval(bool signed, bytes sign, bytes signature);
    mapping(address => bool) public isOwner;
    mapping(string => uint256) public transactionValidations;
    mapping(uint256 => string) public transactionNo;
    mapping(string => uint256) public validSignatures;
    address[] public owners;
    uint256 public signaturesRequired;
    uint256 public nonce;
    uint256 public chainId;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier onlySelf(address owner) {
        require(msg.sender == owner, "Not Self");
        _;
    }

    modifier requireNonZeroSignatures(uint256 _signaturesRequired) {
        require(_signaturesRequired > 0, "Must be non-zero sigs required");
        _;
    }

    constructor(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _signaturesRequired,
        address _factory
    ) payable requireNonZeroSignatures(_signaturesRequired) {
        multiSigFactory = MultiSigFactory(_factory);
        signaturesRequired = _signaturesRequired;
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "constructor: zero address");
            require(!isOwner[owner], "constructor: owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
            emit Owner(owner, isOwner[owner]);
        }

        chainId = _chainId;
    }

    function addSigner(
        address owner,
        address newSigner,
        uint256 newSignaturesRequired
    )
        public
        onlySelf(owner)
        onlyOwner
        requireNonZeroSignatures(newSignaturesRequired)
    {
        require(newSigner != address(0), "addSigner: zero address");
        require(!isOwner[newSigner], "addSigner: owner not unique");
        isOwner[newSigner] = true;
        owners.push(newSigner);
        signaturesRequired = newSignaturesRequired;
        updateSignaturesRequired(owner, newSignaturesRequired);
        emit Owner(newSigner, isOwner[newSigner]);
        multiSigFactory.emitOwners(
            address(this),
            owners,
            newSignaturesRequired
        );
    }

    function removeSigner(
        address owner,
        address oldSigner,
        uint256 newSignaturesRequired
    ) public onlySelf(owner) requireNonZeroSignatures(newSignaturesRequired) {
        require(isOwner[oldSigner], "removeSigner: not owner");
        _removeOwner(oldSigner);
        signaturesRequired = newSignaturesRequired;
        updateSignaturesRequired(owner, newSignaturesRequired);
        emit Owner(oldSigner, isOwner[oldSigner]);
        multiSigFactory.emitOwners(
            address(this),
            owners,
            newSignaturesRequired
        );
    }

    function _removeOwner(address _oldSigner) private {
        isOwner[_oldSigner] = false;
        uint256 ownersLength = owners.length;
        address[] memory poppedOwners = new address[](owners.length);
        for (uint256 i = ownersLength - 1; i >= 0; i--) {
            if (owners[i] != _oldSigner) {
                poppedOwners[i] = owners[i];
                owners.pop();
            } else {
                owners.pop();
                for (uint256 j = i; j < ownersLength - 1; j++) {
                    owners.push(poppedOwners[j]);
                }
                return;
            }
        }
    }

    function updateSignaturesRequired(
        address owner,
        uint256 newSignaturesRequired
    ) internal onlySelf(owner) requireNonZeroSignatures(newSignaturesRequired) {
        signaturesRequired = newSignaturesRequired;
    }

    function getFunctionData(
        string memory functionSignature,
        address owner,
        address newSigner,
        uint256 newSignaturesRequired
    ) public pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                functionSignature,
                owner,
                newSigner,
                newSignaturesRequired
            );
    }

    function executeApproval(
        address payable to,
        uint256 value,
        // bytes memory data,
        bytes memory signature,
        string memory passkey,
        string memory transactionStamp,
        uint256 trxNo
    ) public onlyOwner returns (bool, bytes memory) {
        bytes32 _hash = getMessageHash(passkey);
        address duplicateGuard;
        address recovered = verifyUserSign(passkey, signature);
        require(
            recovered > duplicateGuard,
            "executeTransaction: duplicate or unordered signatures"
        );
        duplicateGuard = recovered;
        bool success;
        if (isOwner[recovered]) {
            validSignatures[transactionStamp]++;
            transactionValidations[transactionStamp] = validSignatures[
                transactionStamp
            ];
            transactionNo[trxNo] = transactionStamp;
            success = true;
        }
        require(
            validSignatures[transactionStamp] >= signaturesRequired,
            "executeTransaction: not enough valid signatures"
        );

        // (bool success, bytes memory result) = to.call{value: value}(data);

        require(success, "executeTransaction: tx failed");

        emit ExecuteTransaction(msg.sender, to, value, trxNo - 1, _hash);

        bytes memory sign = abi.encodeWithSignature("executeApproval(address,uint256,bytes,string,string,uint256 )", to, value, signature, passkey, transactionStamp, trxNo);
        
        emit ExecuteApproval(true, sign, signature);

        return (true, sign);
    }

    function totalTransactionValidations(uint256 trxNo)
        public
        view
        returns (uint256)
    {
        return transactionValidations[transactionNo[nonce]];
    }

    function incrementNonce() public returns (uint256) {
        nonce++;
        return nonce;
    }

    function getTransactionHash(
        uint256 _nonce,
        address to,
        uint256 value
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(address(this), chainId, _nonce, to, value)
            );
    }

    using ECDSA for bytes32;

    function recover(bytes32 _hash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        return _hash.recover(_signature);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

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

    function verifyUserSign(string memory _passkey, bytes memory signature)
        internal
        pure
        returns (address userWalletAddress)
    {
        bytes32 messageHash = getMessageHash(_passkey);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return (recoverSigner(ethSignedMessageHash, signature));
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
