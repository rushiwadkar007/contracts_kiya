
// File: contracts/ECDSA.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// File: contracts/MultiSigFactory.sol


pragma solidity >=0.8.0 <0.9.0;


contract MultiSigFactory {
    MultiSigWallet[] public multiSigs;
    mapping(address => bool) existsMultiSig;
    mapping(address => string) Org;
    mapping(address => string) OrgOwnerEmail;

    event Create(
        uint256 indexed contractId,
        address indexed contractAddress,
        address creator,
        address[] owners,
        uint256 signaturesRequired
    );

    event Owners(
        address indexed contractAddress,
        address[] owners,
        uint256 indexed signaturesRequired
    );

    constructor() {}

    modifier onlyRegistered() {
        require(
            existsMultiSig[msg.sender],
            "caller not registered to use logger"
        );
        _;
    }

    function emitOwners(
        address _contractAddress,
        address[] memory _owners,
        uint256 _signaturesRequired
    ) external onlyRegistered {
        emit Owners(_contractAddress, _owners, _signaturesRequired);
    }

    function create(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _signaturesRequired,
        string memory orgName,
        string memory orgEmail
    ) public payable {
        uint256 id = numberOfMultiSigs();
        MultiSigWallet multiSig = (new MultiSigWallet){value: msg.value}(
            _chainId,
            _owners,
            _signaturesRequired,
            address(this)
        );
        multiSigs.push(multiSig);
        existsMultiSig[address(multiSig)] = true;
        Org[address(multiSig)] = orgName;
        OrgOwnerEmail[address(multiSig)] = orgEmail;
        emit Create(
            id,
            address(multiSig),
            msg.sender,
            _owners,
            _signaturesRequired
        );
        emit Owners(address(multiSig), _owners, _signaturesRequired);
    }

    function numberOfMultiSigs() public view returns (uint256) {
        return multiSigs.length;
    }

    function getMultiSig(uint256 _index)
        public
        view
        returns (
            address multiSigAddress,
            uint256 signaturesRequired,
            uint256 balance,
            string memory organizationName,
            string memory organizationEmail
        )
    {
        MultiSigWallet multiSig = multiSigs[_index];
        return (
            address(multiSig),
            multiSig.signaturesRequired(),
            address(multiSig).balance,
            Org[address(multiSig)],
            OrgOwnerEmail[address(multiSig)]
        );
    }
}
// File: contracts/IMultiSigWallet.sol


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
        string memory transactionStamp
    ) external returns(bool);

    function getTransactionHash(
        uint256 _nonce,
        address to,
        uint256 value
    ) external view returns (
            bytes32
        );

    function recover(bytes32 _hash, bytes memory _signature) external pure returns (address);

    function verifyUserSign(string memory _passkey, bytes memory signature)
        external
        pure
        returns (address userWalletAddress);
}

// File: contracts/MultiSigWallet.sol


pragma solidity >=0.8.0 <0.9.0;

// never forget the OG simple sig wallet: https://github.com/christianlundkvist/simple-multisig/blob/master/contracts/SimpleMultiSig.sol





//ONLY FOR ADMIN LEVEL APPROVAL
contract MultiSigWallet is IMultiSigWallet{
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
    mapping(address => bool) public isOwner;
    mapping(string => uint256) public transactionValidations;
    mapping(uint256 => string) public transactionNo;
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
        string memory transactionStamp
    ) public onlyOwner returns (bool) {
        bytes32 _hash = getMessageHash(passkey);
        address duplicateGuard;
        uint256 validSignatures;
        address recovered = verifyUserSign(passkey, signature);
        require(
            recovered > duplicateGuard,
            "executeTransaction: duplicate or unordered signatures"
        );
        duplicateGuard = recovered;
        bool success;
        if (isOwner[recovered]) {
            validSignatures++;
            transactionValidations[transactionStamp] = validSignatures;
            transactionNo[nonce] = transactionStamp;
            success = true;
        }
        require(
            validSignatures >= signaturesRequired,
            "executeTransaction: not enough valid signatures"
        );

        // (bool success, bytes memory result) = to.call{value: value}(data);

        require(success, "executeTransaction: tx failed");

        emit ExecuteTransaction(msg.sender, to, value, nonce - 1, _hash);
        return true;
    }

    function totalTransactionValidations(uint256 trxNo) public view returns(uint256){
        return transactionValidations[transactionNo[nonce]];
    }

    function incrementNonce() public onlyOwner returns(uint256){
        nonce++;
        return nonce;
    }

    function getTransactionHash(
        uint256 _nonce,
        address to,
        uint256 value
    )
        public
        view
        returns (
            bytes32
        )
    {
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
        public
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
