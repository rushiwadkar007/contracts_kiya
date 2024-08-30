// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

// Sources flattened with hardhat v2.14.0 https://hardhat.org

// File @onchain-id/solidity/contracts/interface/IERC734.sol@v2.1.0

/**
 * @dev interface of the ERC734 (Key Holder) standard as defined in the EIP.
 */
interface IERC734 {

    /**
     * @dev Emitted when an execution request was approved.
     *
     * Specification: MUST be triggered when approve was successfully called.
     */
    event Approved(uint256 indexed executionId, bool approved);

    /**
     * @dev Emitted when an execute operation was approved and successfully performed.
     *
     * Specification: MUST be triggered when approve was called and the execution was successfully approved.
     */
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    /**
     * @dev Emitted when an execution request was performed via `execute`.
     *
     * Specification: MUST be triggered when execute was successfully called.
     */
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    /**
     * @dev Emitted when an execute operation was called and failed
     *
     * Specification: MUST be triggered when execute call failed
     */
    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    /**
     * @dev Emitted when a key was added to the Identity.
     *
     * Specification: MUST be triggered when addKey was successfully called.
     */
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    /**
     * @dev Emitted when a key was removed from the Identity.
     *
     * Specification: MUST be triggered when removeKey was successfully called.
     */
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    /**
     * @dev Adds a _key to the identity. The _purpose specifies the purpose of the key.
     *
     * Triggers Event: `KeyAdded`
     *
     * Specification: MUST only be done by keys of purpose 1, or the identity
     * itself. If it's the identity itself, the approval process will determine its approval.
     */
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) external returns (bool success);

    /**
    * @dev Approves an execution.
    *
    * Triggers Event: `Approved`
    * Triggers on execution successful Event: `Executed`
    * Triggers on execution failure Event: `ExecutionFailed`
    */
    function approve(uint256 _id, bool _approve) external returns (bool success);

    /**
     * @dev Removes _purpose for _key from the identity.
     *
     * Triggers Event: `KeyRemoved`
     *
     * Specification: MUST only be done by keys of purpose 1, or the identity itself.
     * If it's the identity itself, the approval process will determine its approval.
     */
    function removeKey(bytes32 _key, uint256 _purpose) external returns (bool success);

    /**
     * @dev Passes an execution instruction to an ERC734 identity.
     * How the execution is handled is up to the identity implementation:
     * An execution COULD be requested and require `approve` to be called with one or more keys of purpose 1 or 2 to
     * approve this execution.
     * Execute COULD be used as the only accessor for `addKey` and `removeKey`.
     *
     * Triggers Event: ExecutionRequested
     * Triggers on direct execution Event: Executed
     */
    function execute(address _to, uint256 _value, bytes calldata _data) external payable returns (uint256 executionId);

    /**
     * @dev Returns the full key data, if present in the identity.
     */
    function getKey(bytes32 _key) external view returns (uint256[] memory purposes, uint256 keyType, bytes32 key);

    /**
     * @dev Returns the list of purposes associated with a key.
     */
    function getKeyPurposes(bytes32 _key) external view returns(uint256[] memory _purposes);

    /**
     * @dev Returns an array of public key bytes32 held by this identity.
     */
    function getKeysByPurpose(uint256 _purpose) external view returns (bytes32[] memory keys);

    /**
     * @dev Returns TRUE if a key is present and has the given purpose. If the key is not present it returns FALSE.
     */
    function keyHasPurpose(bytes32 _key, uint256 _purpose) external view returns (bool exists);
}

// File @onchain-id/solidity/contracts/interface/IERC735.sol@v2.1.0

/**
 * @dev interface of the ERC735 (Claim Holder) standard as defined in the EIP.
 */
interface IERC735 {

    /**
     * @dev Emitted when a claim was added.
     *
     * Specification: MUST be triggered when a claim was successfully added.
     */
    event ClaimAdded(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri);

    /**
     * @dev Emitted when a claim was removed.
     *
     * Specification: MUST be triggered when removeClaim was successfully called.
     */
    event ClaimRemoved(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri);

    /**
     * @dev Emitted when a claim was changed.
     *
     * Specification: MUST be triggered when addClaim was successfully called on an existing claimId.
     */
    event ClaimChanged(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri);

    /**
     * @dev Add or update a claim.
     *
     * Triggers Event: `ClaimAdded`, `ClaimChanged`
     *
     * Specification: Add or update a claim from an issuer.
     *
     * _signature is a signed message of the following structure:
     * `keccak256(abi.encode(address identityHolder_address, uint256 topic, bytes data))`.
     * Claim IDs are generated using `keccak256(abi.encode(address issuer_address + uint256 topic))`.
     */
    function addClaim(
        uint256 _topic,
        uint256 _scheme,
        address issuer,
        bytes calldata _signature,
        bytes calldata _data,
        string calldata _uri)
    external returns (bytes32 claimRequestId);

    /**
     * @dev Removes a claim.
     *
     * Triggers Event: `ClaimRemoved`
     *
     * Claim IDs are generated using `keccak256(abi.encode(address issuer_address, uint256 topic))`.
     */
    function removeClaim(bytes32 _claimId) external returns (bool success);

    /**
     * @dev Get a claim by its ID.
     *
     * Claim IDs are generated using `keccak256(abi.encode(address issuer_address, uint256 topic))`.
     */
    function getClaim(bytes32 _claimId)
    external view returns(
        uint256 topic,
        uint256 scheme,
        address issuer,
        bytes memory signature,
        bytes memory data,
        string memory uri);

    /**
     * @dev Returns an array of claim IDs by topic.
     */
    function getClaimIdsByTopic(uint256 _topic) external view returns(bytes32[] memory claimIds);
}

// File @onchain-id/solidity/contracts/interface/IIdentity.sol@v2.1.0

// solhint-disable-next-line no-empty-blocks
interface IIdentity is IERC734, IERC735 {}

// File @onchain-id/solidity/contracts/interface/IClaimIssuer.sol@v2.1.0

interface IClaimIssuer is IIdentity {

    /**
     * @dev Emitted when a claim is revoked.
     *
     * Specification: MUST be triggered when revoking a claim.
     */
    event ClaimRevoked(bytes indexed signature);

    /**
     * @dev Revoke a claim previously issued, the claim is no longer considered as valid after revocation.
     * @notice will fetch the claim from the identity contract (unsafe).
     * @param _claimId the id of the claim
     * @param _identity the address of the identity contract
     * @return isRevoked true when the claim is revoked
     */
    function revokeClaim(bytes32 _claimId, address _identity) external returns(bool);

    /**
     * @dev Revoke a claim previously issued, the claim is no longer considered as valid after revocation.
     * @param signature the signature of the claim
     */
    function revokeClaimBySignature(bytes calldata signature) external;

    /**
     * @dev Returns revocation status of a claim.
     * @param _sig the signature of the claim
     * @return isRevoked true if the claim is revoked and false otherwise
     */
    function isClaimRevoked(bytes calldata _sig) external view returns (bool);

    /**
     * @dev Checks if a claim is valid.
     * @param _identity the identity contract related to the claim
     * @param claimTopic the claim topic of the claim
     * @param sig the signature of the claim
     * @param data the data field of the claim
     * @return claimValid true if the claim is valid, false otherwise
     */
    function isClaimValid(
        IIdentity _identity,
        uint256 claimTopic,
        bytes calldata sig,
        bytes calldata data)
    external view returns (bool);

    /**
     * @dev returns the address that signed the given data
     * @param sig the signature of the data
     * @param dataHash the data that was signed
     * returns the address that signed dataHash and created the signature sig
     */
    function getRecoveredAddress(bytes calldata sig, bytes32 dataHash) external pure returns (address);
}

// File @openzeppelin/contracts/utils/Context.sol@v4.9.3

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File @openzeppelin/contracts/access/Ownable.sol@v4.9.3

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File contracts/registry/interface/IClaimTopicsRegistry.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//
/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

interface IClaimTopicsRegistry {
    /**
     *  this event is emitted when a claim topic has been added to the ClaimTopicsRegistry
     *  the event is emitted by the 'addClaimTopic' function
     *  `claimTopic` is the required claim added to the Claim Topics Registry
     */
    event ClaimTopicAdded(uint256 indexed claimTopic);

    /**
     *  this event is emitted when a claim topic has been removed from the ClaimTopicsRegistry
     *  the event is emitted by the 'removeClaimTopic' function
     *  `claimTopic` is the required claim removed from the Claim Topics Registry
     */
    event ClaimTopicRemoved(uint256 indexed claimTopic);

    /**
     * @dev Add a trusted claim topic (For example: KYC=1, AML=2).
     * Only owner can call.
     * emits `ClaimTopicAdded` event
     * cannot add more than 15 topics for 1 token as adding more could create gas issues
     * @param _claimTopic The claim topic index
     */
    function addClaimTopic(uint256 _claimTopic) external;

    /**
     *  @dev Remove a trusted claim topic (For example: KYC=1, AML=2).
     *  Only owner can call.
     *  emits `ClaimTopicRemoved` event
     *  @param _claimTopic The claim topic index
     */
    function removeClaimTopic(uint256 _claimTopic) external;

    /**
     *  @dev Get the trusted claim topics for the security token
     *  @return Array of trusted claim topics
     */
    function getClaimTopics() external view returns (uint256[] memory);
}

// File contracts/registry/interface/IIdentityRegistryStorage.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//
/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

interface IIdentityRegistryStorage {

    /// events

    /**
     *  this event is emitted when an Identity is registered into the storage contract.
     *  the event is emitted by the 'registerIdentity' function
     *  `investorAddress` is the address of the investor's wallet
     *  `identity` is the address of the Identity smart contract (onchainID)
     */
    event IdentityStored(address indexed investorAddress, IIdentity indexed identity);

    /**
     *  this event is emitted when an Identity is removed from the storage contract.
     *  the event is emitted by the 'deleteIdentity' function
     *  `investorAddress` is the address of the investor's wallet
     *  `identity` is the address of the Identity smart contract (onchainID)
     */
    event IdentityUnstored(address indexed investorAddress, IIdentity indexed identity);

    /**
     *  this event is emitted when an Identity has been updated
     *  the event is emitted by the 'updateIdentity' function
     *  `oldIdentity` is the old Identity contract's address to update
     *  `newIdentity` is the new Identity contract's
     */
    event IdentityModified(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);

    /**
     *  this event is emitted when an Identity's country has been updated
     *  the event is emitted by the 'updateCountry' function
     *  `investorAddress` is the address on which the country has been updated
     *  `country` is the numeric code (ISO 3166-1) of the new country
     */
    event CountryModified(address indexed investorAddress, uint16 indexed country);

    /**
     *  this event is emitted when an Identity Registry is bound to the storage contract
     *  the event is emitted by the 'addIdentityRegistry' function
     *  `identityRegistry` is the address of the identity registry added
     */
    event IdentityRegistryBound(address indexed identityRegistry);

    /**
     *  this event is emitted when an Identity Registry is unbound from the storage contract
     *  the event is emitted by the 'removeIdentityRegistry' function
     *  `identityRegistry` is the address of the identity registry removed
     */
    event IdentityRegistryUnbound(address indexed identityRegistry);

    /// functions

    /**
     *  @dev adds an identity contract corresponding to a user address in the storage.
     *  Requires that the user doesn't have an identity contract already registered.
     *  This function can only be called by an address set as agent of the smart contract
     *  @param _userAddress The address of the user
     *  @param _identity The address of the user's identity contract
     *  @param _country The country of the investor
     *  emits `IdentityStored` event
     */
    function addIdentityToStorage(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external;

    /**
     *  @dev Removes an user from the storage.
     *  Requires that the user have an identity contract already deployed that will be deleted.
     *  This function can only be called by an address set as agent of the smart contract
     *  @param _userAddress The address of the user to be removed
     *  emits `IdentityUnstored` event
     */
    function removeIdentityFromStorage(address _userAddress) external;

    /**
     *  @dev Updates the country corresponding to a user address.
     *  Requires that the user should have an identity contract already deployed that will be replaced.
     *  This function can only be called by an address set as agent of the smart contract
     *  @param _userAddress The address of the user
     *  @param _country The new country of the user
     *  emits `CountryModified` event
     */
    function modifyStoredInvestorCountry(address _userAddress, uint16 _country) external;

    /**
     *  @dev Updates an identity contract corresponding to a user address.
     *  Requires that the user address should be the owner of the identity contract.
     *  Requires that the user should have an identity contract already deployed that will be replaced.
     *  This function can only be called by an address set as agent of the smart contract
     *  @param _userAddress The address of the user
     *  @param _identity The address of the user's new identity contract
     *  emits `IdentityModified` event
     */
    function modifyStoredIdentity(address _userAddress, IIdentity _identity) external;

    /**
     *  @notice Adds an identity registry as agent of the Identity Registry Storage Contract.
     *  This function can only be called by the wallet set as owner of the smart contract
     *  This function adds the identity registry to the list of identityRegistries linked to the storage contract
     *  cannot bind more than 300 IR to 1 IRS
     *  @param _identityRegistry The identity registry address to add.
     */
    function bindIdentityRegistry(address _identityRegistry) external;

    /**
     *  @notice Removes an identity registry from being agent of the Identity Registry Storage Contract.
     *  This function can only be called by the wallet set as owner of the smart contract
     *  This function removes the identity registry from the list of identityRegistries linked to the storage contract
     *  @param _identityRegistry The identity registry address to remove.
     */
    function unbindIdentityRegistry(address _identityRegistry) external;

    /**
     *  @dev Returns the identity registries linked to the storage contract
     */
    function linkedIdentityRegistries() external view returns (address[] memory);

    /**
     *  @dev Returns the onchainID of an investor.
     *  @param _userAddress The wallet of the investor
     */
    function storedIdentity(address _userAddress) external view returns (IIdentity);

    /**
     *  @dev Returns the country code of an investor.
     *  @param _userAddress The wallet of the investor
     */
    function storedInvestorCountry(address _userAddress) external view returns (uint16);
}

// File contracts/registry/interface/ITrustedIssuersRegistry.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//

/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

interface ITrustedIssuersRegistry {
    /**
     *  this event is emitted when a trusted issuer is added in the registry.
     *  the event is emitted by the addTrustedIssuer function
     *  `trustedIssuer` is the address of the trusted issuer's ClaimIssuer contract
     *  `claimTopics` is the set of claims that the trusted issuer is allowed to emit
     */
    event TrustedIssuerAdded(IClaimIssuer indexed trustedIssuer, uint256[] claimTopics);

    /**
     *  this event is emitted when a trusted issuer is removed from the registry.
     *  the event is emitted by the removeTrustedIssuer function
     *  `trustedIssuer` is the address of the trusted issuer's ClaimIssuer contract
     */
    event TrustedIssuerRemoved(IClaimIssuer indexed trustedIssuer);

    /**
     *  this event is emitted when the set of claim topics is changed for a given trusted issuer.
     *  the event is emitted by the updateIssuerClaimTopics function
     *  `trustedIssuer` is the address of the trusted issuer's ClaimIssuer contract
     *  `claimTopics` is the set of claims that the trusted issuer is allowed to emit
     */
    event ClaimTopicsUpdated(IClaimIssuer indexed trustedIssuer, uint256[] claimTopics);

    /**
     *  @dev registers a ClaimIssuer contract as trusted claim issuer.
     *  Requires that a ClaimIssuer contract doesn't already exist
     *  Requires that the claimTopics set is not empty
     *  Requires that there is no more than 15 claimTopics
     *  Requires that there is no more than 50 Trusted issuers
     *  @param _trustedIssuer The ClaimIssuer contract address of the trusted claim issuer.
     *  @param _claimTopics the set of claim topics that the trusted issuer is allowed to emit
     *  This function can only be called by the owner of the Trusted Issuers Registry contract
     *  emits a `TrustedIssuerAdded` event
     */
    function addTrustedIssuer(IClaimIssuer _trustedIssuer, uint256[] calldata _claimTopics) external;

    /**
     *  @dev Removes the ClaimIssuer contract of a trusted claim issuer.
     *  Requires that the claim issuer contract to be registered first
     *  @param _trustedIssuer the claim issuer to remove.
     *  This function can only be called by the owner of the Trusted Issuers Registry contract
     *  emits a `TrustedIssuerRemoved` event
     */
    function removeTrustedIssuer(IClaimIssuer _trustedIssuer) external;

    /**
     *  @dev Updates the set of claim topics that a trusted issuer is allowed to emit.
     *  Requires that this ClaimIssuer contract already exists in the registry
     *  Requires that the provided claimTopics set is not empty
     *  Requires that there is no more than 15 claimTopics
     *  @param _trustedIssuer the claim issuer to update.
     *  @param _claimTopics the set of claim topics that the trusted issuer is allowed to emit
     *  This function can only be called by the owner of the Trusted Issuers Registry contract
     *  emits a `ClaimTopicsUpdated` event
     */
    function updateIssuerClaimTopics(IClaimIssuer _trustedIssuer, uint256[] calldata _claimTopics) external;

    /**
     *  @dev Function for getting all the trusted claim issuers stored.
     *  @return array of all claim issuers registered.
     */
    function getTrustedIssuers() external view returns (IClaimIssuer[] memory);

    /**
     *  @dev Function for getting all the trusted issuer allowed for a given claim topic.
     *  @param claimTopic the claim topic to get the trusted issuers for.
     *  @return array of all claim issuer addresses that are allowed for the given claim topic.
     */
    function getTrustedIssuersForClaimTopic(uint256 claimTopic) external view returns (IClaimIssuer[] memory);

    /**
     *  @dev Checks if the ClaimIssuer contract is trusted
     *  @param _issuer the address of the ClaimIssuer contract
     *  @return true if the issuer is trusted, false otherwise.
     */
    function isTrustedIssuer(address _issuer) external view returns (bool);

    /**
     *  @dev Function for getting all the claim topic of trusted claim issuer
     *  Requires the provided ClaimIssuer contract to be registered in the trusted issuers registry.
     *  @param _trustedIssuer the trusted issuer concerned.
     *  @return The set of claim topics that the trusted issuer is allowed to emit
     */
    function getTrustedIssuerClaimTopics(IClaimIssuer _trustedIssuer) external view returns (uint256[] memory);

    /**
     *  @dev Function for checking if the trusted claim issuer is allowed
     *  to emit a certain claim topic
     *  @param _issuer the address of the trusted issuer's ClaimIssuer contract
     *  @param _claimTopic the Claim Topic that has to be checked to know if the `issuer` is allowed to emit it
     *  @return true if the issuer is trusted for this claim topic.
     */
    function hasClaimTopic(address _issuer, uint256 _claimTopic) external view returns (bool);
}

// File contracts/registry/interface/IIdentityRegistry.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//
/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

interface IIdentityRegistry {
    /**
     *  this event is emitted when the ClaimTopicsRegistry has been set for the IdentityRegistry
     *  the event is emitted by the IdentityRegistry constructor
     *  `claimTopicsRegistry` is the address of the Claim Topics Registry contract
     */
    event ClaimTopicsRegistrySet(address indexed claimTopicsRegistry);

    /**
     *  this event is emitted when the IdentityRegistryStorage has been set for the IdentityRegistry
     *  the event is emitted by the IdentityRegistry constructor
     *  `identityStorage` is the address of the Identity Registry Storage contract
     */
    event IdentityStorageSet(address indexed identityStorage);

    /**
     *  this event is emitted when the TrustedIssuersRegistry has been set for the IdentityRegistry
     *  the event is emitted by the IdentityRegistry constructor
     *  `trustedIssuersRegistry` is the address of the Trusted Issuers Registry contract
     */
    event TrustedIssuersRegistrySet(address indexed trustedIssuersRegistry);

    /**
     *  this event is emitted when an Identity is registered into the Identity Registry.
     *  the event is emitted by the 'registerIdentity' function
     *  `investorAddress` is the address of the investor's wallet
     *  `identity` is the address of the Identity smart contract (onchainID)
     */
    event IdentityRegistered(address indexed investorAddress, IIdentity indexed identity);

    /**
     *  this event is emitted when an Identity is removed from the Identity Registry.
     *  the event is emitted by the 'deleteIdentity' function
     *  `investorAddress` is the address of the investor's wallet
     *  `identity` is the address of the Identity smart contract (onchainID)
     */
    event IdentityRemoved(address indexed investorAddress, IIdentity indexed identity);

    /**
     *  this event is emitted when an Identity has been updated
     *  the event is emitted by the 'updateIdentity' function
     *  `oldIdentity` is the old Identity contract's address to update
     *  `newIdentity` is the new Identity contract's
     */
    event IdentityUpdated(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);

    /**
     *  this event is emitted when an Identity's country has been updated
     *  the event is emitted by the 'updateCountry' function
     *  `investorAddress` is the address on which the country has been updated
     *  `country` is the numeric code (ISO 3166-1) of the new country
     */
    event CountryUpdated(address indexed investorAddress, uint16 indexed country);

    /**
     *  @dev Register an identity contract corresponding to a user address.
     *  Requires that the user doesn't have an identity contract already registered.
     *  This function can only be called by a wallet set as agent of the smart contract
     *  @param _userAddress The address of the user
     *  @param _identity The address of the user's identity contract
     *  @param _country The country of the investor
     *  emits `IdentityRegistered` event
     */
    function registerIdentity(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external;

    /**
     *  @dev Removes an user from the identity registry.
     *  Requires that the user have an identity contract already deployed that will be deleted.
     *  This function can only be called by a wallet set as agent of the smart contract
     *  @param _userAddress The address of the user to be removed
     *  emits `IdentityRemoved` event
     */
    function deleteIdentity(address _userAddress) external;

    /**
     *  @dev Replace the actual identityRegistryStorage contract with a new one.
     *  This function can only be called by the wallet set as owner of the smart contract
     *  @param _identityRegistryStorage The address of the new Identity Registry Storage
     *  emits `IdentityStorageSet` event
     */
    function setIdentityRegistryStorage(address _identityRegistryStorage) external;

    /**
     *  @dev Replace the actual claimTopicsRegistry contract with a new one.
     *  This function can only be called by the wallet set as owner of the smart contract
     *  @param _claimTopicsRegistry The address of the new claim Topics Registry
     *  emits `ClaimTopicsRegistrySet` event
     */
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;

    /**
     *  @dev Replace the actual trustedIssuersRegistry contract with a new one.
     *  This function can only be called by the wallet set as owner of the smart contract
     *  @param _trustedIssuersRegistry The address of the new Trusted Issuers Registry
     *  emits `TrustedIssuersRegistrySet` event
     */
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;

    /**
     *  @dev Updates the country corresponding to a user address.
     *  Requires that the user should have an identity contract already deployed that will be replaced.
     *  This function can only be called by a wallet set as agent of the smart contract
     *  @param _userAddress The address of the user
     *  @param _country The new country of the user
     *  emits `CountryUpdated` event
     */
    function updateCountry(address _userAddress, uint16 _country) external;

    /**
     *  @dev Updates an identity contract corresponding to a user address.
     *  Requires that the user address should be the owner of the identity contract.
     *  Requires that the user should have an identity contract already deployed that will be replaced.
     *  This function can only be called by a wallet set as agent of the smart contract
     *  @param _userAddress The address of the user
     *  @param _identity The address of the user's new identity contract
     *  emits `IdentityUpdated` event
     */
    function updateIdentity(address _userAddress, IIdentity _identity) external;

    /**
     *  @dev function allowing to register identities in batch
     *  This function can only be called by a wallet set as agent of the smart contract
     *  Requires that none of the users has an identity contract already registered.
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_userAddresses.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _userAddresses The addresses of the users
     *  @param _identities The addresses of the corresponding identity contracts
     *  @param _countries The countries of the corresponding investors
     *  emits _userAddresses.length `IdentityRegistered` events
     */
    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        IIdentity[] calldata _identities,
        uint16[] calldata _countries
    ) external;

    /**
     *  @dev This functions checks whether a wallet has its Identity registered or not
     *  in the Identity Registry.
     *  @param _userAddress The address of the user to be checked.
     *  @return 'True' if the address is contained in the Identity Registry, 'false' if not.
     */
    function contains(address _userAddress) external view returns (bool);

    /**
     *  @dev This functions checks whether an identity contract
     *  corresponding to the provided user address has the required claims or not based
     *  on the data fetched from trusted issuers registry and from the claim topics registry
     *  @param _userAddress The address of the user to be verified.
     *  @return 'True' if the address is verified, 'false' if not.
     */
    function isVerified(address _userAddress) external view returns (bool);

    /**
     *  @dev Returns the onchainID of an investor.
     *  @param _userAddress The wallet of the investor
     */
    function identity(address _userAddress) external view returns (IIdentity);

    /**
     *  @dev Returns the country code of an investor.
     *  @param _userAddress The wallet of the investor
     */
    function investorCountry(address _userAddress) external view returns (uint16);

    /**
     *  @dev Returns the IdentityRegistryStorage linked to the current IdentityRegistry.
     */
    function identityStorage() external view returns (IIdentityRegistryStorage);

    /**
     *  @dev Returns the TrustedIssuersRegistry linked to the current IdentityRegistry.
     */
    function issuersRegistry() external view returns (ITrustedIssuersRegistry);

    /**
     *  @dev Returns the ClaimTopicsRegistry linked to the current IdentityRegistry.
     */
    function topicsRegistry() external view returns (IClaimTopicsRegistry);
}

// File contracts/roles/Roles.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//

/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File contracts/roles/AgentRole.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//

/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

contract AgentRole is Ownable {
    using Roles for Roles.Role;

    Roles.Role private _agents;

    event AgentAdded(address indexed _agent);
    event AgentRemoved(address indexed _agent);

    modifier onlyAgent() {
        require(isAgent(msg.sender), "AgentRole: caller does not have the Agent role");
        _;
    }

    function addAgent(address _agent) public onlyOwner {
        require(_agent != address(0), "invalid argument - zero address");
        _agents.add(_agent);
        emit AgentAdded(_agent);
    }

    function removeAgent(address _agent) public onlyOwner {
        require(_agent != address(0), "invalid argument - zero address");
        _agents.remove(_agent);
        emit AgentRemoved(_agent);
    }

    function isAgent(address _agent) public view returns (bool) {
        return _agents.has(_agent);
    }
}

// File contracts/compliance/legacy/ICompliance.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//
/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

interface ICompliance {
    /**
     *  this event is emitted when the Agent has been added on the allowedList of this Compliance.
     *  the event is emitted by the Compliance constructor and by the addTokenAgent function
     *  `_agentAddress` is the address of the Agent to add
     */
    event TokenAgentAdded(address _agentAddress);

    /**
     *  this event is emitted when the Agent has been removed from the agent list of this Compliance.
     *  the event is emitted by the Compliance constructor and by the removeTokenAgent function
     *  `_agentAddress` is the address of the Agent to remove
     */
    event TokenAgentRemoved(address _agentAddress);

    /**
     *  this event is emitted when a token has been bound to the compliance contract
     *  the event is emitted by the bindToken function
     *  `_token` is the address of the token to bind
     */
    event TokenBound(address _token);

    /**
     *  this event is emitted when a token has been unbound from the compliance contract
     *  the event is emitted by the unbindToken function
     *  `_token` is the address of the token to unbind
     */
    event TokenUnbound(address _token);

    /**
     *  @dev adds an agent to the list of token agents
     *  @param _agentAddress address of the agent to be added
     *  Emits a TokenAgentAdded event
     */
    function addTokenAgent(address _agentAddress) external;

    /**
     *  @dev remove Agent from the list of token agents
     *  @param _agentAddress address of the agent to be removed (must be added first)
     *  Emits a TokenAgentRemoved event
     */
    function removeTokenAgent(address _agentAddress) external;

    /**
     *  @dev binds a token to the compliance contract
     *  @param _token address of the token to bind
     *  Emits a TokenBound event
     */
    function bindToken(address _token) external;

    /**
     *  @dev unbinds a token from the compliance contract
     *  @param _token address of the token to unbind
     *  Emits a TokenUnbound event
     */
    function unbindToken(address _token) external;

    /**
     *  @dev function called whenever tokens are transferred
     *  from one wallet to another
     *  this function can update state variables in the compliance contract
     *  these state variables being used by `canTransfer` to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the compliance smart contract
     *  @param _from The address of the sender
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function transferred(
        address _from,
        address _to,
        uint256 _amount
    ) external;

    /**
     *  @dev function called whenever tokens are created
     *  on a wallet
     *  this function can update state variables in the compliance contract
     *  these state variables being used by `canTransfer` to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the compliance smart contract
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function created(address _to, uint256 _amount) external;

    /**
     *  @dev function called whenever tokens are destroyed
     *  this function can update state variables in the compliance contract
     *  these state variables being used by `canTransfer` to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the compliance smart contract
     *  @param _from The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function destroyed(address _from, uint256 _amount) external;

    /**
     *  @dev Returns true if the Address is in the list of token agents
     *  @param _agentAddress address of this agent
     */
    function isTokenAgent(address _agentAddress) external view returns (bool);

    /**
     *  @dev Returns true if the address given corresponds to a token that is bound with the Compliance contract
     *  @param _token address of the token
     */
    function isTokenBound(address _token) external view returns (bool);

    /**
     *  @dev checks that the transfer is compliant.
     *  default compliance always returns true
     *  READ ONLY FUNCTION, this function cannot be used to increment
     *  counters, emit events, ...
     *  @param _from The address of the sender
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool);
}

// File contracts/roles/permissioning/owner/OwnerRoles.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//

/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

contract OwnerRoles is Ownable {
    using Roles for Roles.Role;

    /// variables

    Roles.Role private _ownerAdmin;
    Roles.Role private _registryAddressSetter;
    Roles.Role private _complianceSetter;
    Roles.Role private _complianceManager;
    Roles.Role private _claimRegistryManager;
    Roles.Role private _issuersRegistryManager;
    Roles.Role private _tokenInfoManager;

    /// events

    event RoleAdded(address indexed _owner, string _role);
    event RoleRemoved(address indexed _owner, string _role);

    /// modifiers

    modifier onlyAdmin() {
        require(owner() == msg.sender || isOwnerAdmin(_msgSender()), "Role: Sender is NOT Admin");
        _;
    }

    /// functions

    function addOwnerAdmin(address _owner) external onlyAdmin {
        _ownerAdmin.add(_owner);
        string memory _role = "OwnerAdmin";
        emit RoleAdded(_owner, _role);
    }

    function removeOwnerAdmin(address _owner) external onlyAdmin {
        _ownerAdmin.remove(_owner);
        string memory _role = "OwnerAdmin";
        emit RoleRemoved(_owner, _role);
    }

    function addRegistryAddressSetter(address _owner) external onlyAdmin {
        _registryAddressSetter.add(_owner);
        string memory _role = "RegistryAddressSetter";
        emit RoleAdded(_owner, _role);
    }

    function removeRegistryAddressSetter(address _owner) external onlyAdmin {
        _registryAddressSetter.remove(_owner);
        string memory _role = "RegistryAddressSetter";
        emit RoleRemoved(_owner, _role);
    }

    function addComplianceSetter(address _owner) external onlyAdmin {
        _complianceSetter.add(_owner);
        string memory _role = "ComplianceSetter";
        emit RoleAdded(_owner, _role);
    }

    function removeComplianceSetter(address _owner) external onlyAdmin {
        _complianceSetter.remove(_owner);
        string memory _role = "ComplianceSetter";
        emit RoleRemoved(_owner, _role);
    }

    function addComplianceManager(address _owner) external onlyAdmin {
        _complianceManager.add(_owner);
        string memory _role = "ComplianceManager";
        emit RoleAdded(_owner, _role);
    }

    function removeComplianceManager(address _owner) external onlyAdmin {
        _complianceManager.remove(_owner);
        string memory _role = "ComplianceManager";
        emit RoleRemoved(_owner, _role);
    }

    function addClaimRegistryManager(address _owner) external onlyAdmin {
        _claimRegistryManager.add(_owner);
        string memory _role = "ClaimRegistryManager";
        emit RoleAdded(_owner, _role);
    }

    function removeClaimRegistryManager(address _owner) external onlyAdmin {
        _claimRegistryManager.remove(_owner);
        string memory _role = "ClaimRegistryManager";
        emit RoleRemoved(_owner, _role);
    }

    function addIssuersRegistryManager(address _owner) external onlyAdmin {
        _issuersRegistryManager.add(_owner);
        string memory _role = "IssuersRegistryManager";
        emit RoleAdded(_owner, _role);
    }

    function removeIssuersRegistryManager(address _owner) external onlyAdmin {
        _issuersRegistryManager.remove(_owner);
        string memory _role = "IssuersRegistryManager";
        emit RoleRemoved(_owner, _role);
    }

    function addTokenInfoManager(address _owner) external onlyAdmin {
        _tokenInfoManager.add(_owner);
        string memory _role = "TokenInfoManager";
        emit RoleAdded(_owner, _role);
    }

    function removeTokenInfoManager(address _owner) external onlyAdmin {
        _tokenInfoManager.remove(_owner);
        string memory _role = "TokenInfoManager";
        emit RoleRemoved(_owner, _role);
    }

    function isOwnerAdmin(address _owner) public view returns (bool) {
        return _ownerAdmin.has(_owner);
    }

    function isTokenInfoManager(address _owner) public view returns (bool) {
        return _tokenInfoManager.has(_owner);
    }

    function isIssuersRegistryManager(address _owner) public view returns (bool) {
        return _issuersRegistryManager.has(_owner);
    }

    function isClaimRegistryManager(address _owner) public view returns (bool) {
        return _claimRegistryManager.has(_owner);
    }

    function isComplianceManager(address _owner) public view returns (bool) {
        return _complianceManager.has(_owner);
    }

    function isComplianceSetter(address _owner) public view returns (bool) {
        return _complianceSetter.has(_owner);
    }

    function isRegistryAddressSetter(address _owner) public view returns (bool) {
        return _registryAddressSetter.has(_owner);
    }
}

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File contracts/compliance/modular/IModularCompliance.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//
/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

interface IModularCompliance {

    /// events

    /**
     *  @dev Event emitted for each executed interaction with a module contract.
     *  For gas efficiency, only the interaction calldata selector (first 4
     *  bytes) is included in the event. For interactions without calldata or
     *  whose calldata is shorter than 4 bytes, the selector will be `0`.
     */
    event ModuleInteraction(address indexed target, bytes4 selector);

    /**
     *  this event is emitted when a token has been bound to the compliance contract
     *  the event is emitted by the bindToken function
     *  `_token` is the address of the token to bind
     */
    event TokenBound(address _token);

    /**
     *  this event is emitted when a token has been unbound from the compliance contract
     *  the event is emitted by the unbindToken function
     *  `_token` is the address of the token to unbind
     */
    event TokenUnbound(address _token);

    /**
     *  this event is emitted when a module has been added to the list of modules bound to the compliance contract
     *  the event is emitted by the addModule function
     *  `_module` is the address of the compliance module
     */
    event ModuleAdded(address indexed _module);

    /**
     *  this event is emitted when a module has been removed from the list of modules bound to the compliance contract
     *  the event is emitted by the removeModule function
     *  `_module` is the address of the compliance module
     */
    event ModuleRemoved(address indexed _module);

    /// functions

    /**
     *  @dev binds a token to the compliance contract
     *  @param _token address of the token to bind
     *  This function can be called ONLY by the owner of the compliance contract
     *  Emits a TokenBound event
     */
    function bindToken(address _token) external;

    /**
     *  @dev unbinds a token from the compliance contract
     *  @param _token address of the token to unbind
     *  This function can be called ONLY by the owner of the compliance contract
     *  Emits a TokenUnbound event
     */
    function unbindToken(address _token) external;

    /**
     *  @dev adds a module to the list of compliance modules
     *  @param _module address of the module to add
     *  there cannot be more than 25 modules bound to the modular compliance for gas cost reasons
     *  This function can be called ONLY by the owner of the compliance contract
     *  Emits a ModuleAdded event
     */
    function addModule(address _module) external;

    /**
     *  @dev removes a module from the list of compliance modules
     *  @param _module address of the module to remove
     *  This function can be called ONLY by the owner of the compliance contract
     *  Emits a ModuleRemoved event
     */
    function removeModule(address _module) external;

    /**
     *  @dev calls any function on bound modules
     *  can be called only on bound modules
     *  @param callData the bytecode for interaction with the module, abi encoded
     *  @param _module The address of the module
     *  This function can be called only by the modular compliance owner
     *  emits a `ModuleInteraction` event
     */
    function callModuleFunction(bytes calldata callData, address _module) external;

    /**
     *  @dev function called whenever tokens are transferred
     *  from one wallet to another
     *  this function can update state variables in the modules bound to the compliance
     *  these state variables being used by the module checks to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the modules
     *  This function can be called ONLY by the token contract bound to the compliance
     *  @param _from The address of the sender
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     *  This function calls moduleTransferAction() on each module bound to the compliance contract
     */
    function transferred(
        address _from,
        address _to,
        uint256 _amount
    ) external;

    /**
     *  @dev function called whenever tokens are created on a wallet
     *  this function can update state variables in the modules bound to the compliance
     *  these state variables being used by the module checks to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the modules
     *  This function can be called ONLY by the token contract bound to the compliance
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the minting
     *  This function calls moduleMintAction() on each module bound to the compliance contract
     */
    function created(address _to, uint256 _amount) external;

    /**
     *  @dev function called whenever tokens are destroyed from a wallet
     *  this function can update state variables in the modules bound to the compliance
     *  these state variables being used by the module checks to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the modules
     *  This function can be called ONLY by the token contract bound to the compliance
     *  @param _from The address on which tokens are burnt
     *  @param _amount The amount of tokens involved in the burn
     *  This function calls moduleBurnAction() on each module bound to the compliance contract
     */
    function destroyed(address _from, uint256 _amount) external;

    /**
     *  @dev checks that the transfer is compliant.
     *  default compliance always returns true
     *  READ ONLY FUNCTION, this function cannot be used to increment
     *  counters, emit events, ...
     *  @param _from The address of the sender
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     *  This function will call moduleCheck() on every module bound to the compliance
     *  If each of the module checks return TRUE, this function will return TRUE as well
     *  returns FALSE otherwise
     */
    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool);

    /**
     *  @dev getter for the modules bound to the compliance contract
     *  returns address array of module contracts bound to the compliance
     */
    function getModules() external view returns (address[] memory);

    /**
     *  @dev getter for the address of the token bound
     *  returns the address of the token
     */
    function getTokenBound() external view returns (address);

    /**
     *  @dev checks if a module is bound to the compliance contract
     *  returns true if module is bound, false otherwise
     */
    function isModuleBound(address _module) external view returns (bool);
}

// File contracts/token/IToken.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//

/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

/// @dev interface
interface IToken is IERC20 {

    /// events

    /**
     *  this event is emitted when the token information is updated.
     *  the event is emitted by the token init function and by the setTokenInformation function
     *  `_newName` is the name of the token
     *  `_newSymbol` is the symbol of the token
     *  `_newDecimals` is the decimals of the token
     *  `_newVersion` is the version of the token, current version is 3.0
     *  `_newOnchainID` is the address of the onchainID of the token
     */
    event UpdatedTokenInformation(string indexed _newName, string indexed _newSymbol, uint8 _newDecimals, string
    _newVersion, address indexed _newOnchainID);

    /**
     *  this event is emitted when the IdentityRegistry has been set for the token
     *  the event is emitted by the token constructor and by the setIdentityRegistry function
     *  `_identityRegistry` is the address of the Identity Registry of the token
     */
    event IdentityRegistryAdded(address indexed _identityRegistry);

    /**
     *  this event is emitted when the Compliance has been set for the token
     *  the event is emitted by the token constructor and by the setCompliance function
     *  `_compliance` is the address of the Compliance contract of the token
     */
    event ComplianceAdded(address indexed _compliance);

    /**
     *  this event is emitted when an investor successfully recovers his tokens
     *  the event is emitted by the recoveryAddress function
     *  `_lostWallet` is the address of the wallet that the investor lost access to
     *  `_newWallet` is the address of the wallet that the investor provided for the recovery
     *  `_investorOnchainID` is the address of the onchainID of the investor who asked for a recovery
     */
    event RecoverySuccess(address indexed _lostWallet, address indexed _newWallet, address indexed _investorOnchainID);

    /**
     *  this event is emitted when the wallet of an investor is frozen or unfrozen
     *  the event is emitted by setAddressFrozen and batchSetAddressFrozen functions
     *  `_userAddress` is the wallet of the investor that is concerned by the freezing status
     *  `_isFrozen` is the freezing status of the wallet
     *  if `_isFrozen` equals `true` the wallet is frozen after emission of the event
     *  if `_isFrozen` equals `false` the wallet is unfrozen after emission of the event
     *  `_owner` is the address of the agent who called the function to freeze the wallet
     */
    event AddressFrozen(address indexed _userAddress, bool indexed _isFrozen, address indexed _owner);

    /**
     *  this event is emitted when a certain amount of tokens is frozen on a wallet
     *  the event is emitted by freezePartialTokens and batchFreezePartialTokens functions
     *  `_userAddress` is the wallet of the investor that is concerned by the freezing status
     *  `_amount` is the amount of tokens that are frozen
     */
    event TokensFrozen(address indexed _userAddress, uint256 _amount);

    /**
     *  this event is emitted when a certain amount of tokens is unfrozen on a wallet
     *  the event is emitted by unfreezePartialTokens and batchUnfreezePartialTokens functions
     *  `_userAddress` is the wallet of the investor that is concerned by the freezing status
     *  `_amount` is the amount of tokens that are unfrozen
     */
    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);

    /**
     *  this event is emitted when the token is paused
     *  the event is emitted by the pause function
     *  `_userAddress` is the address of the wallet that called the pause function
     */
    event Paused(address _userAddress);

    /**
     *  this event is emitted when the token is unpaused
     *  the event is emitted by the unpause function
     *  `_userAddress` is the address of the wallet that called the unpause function
     */
    event Unpaused(address _userAddress);

    /// functions

    /**
     *  @dev sets the token name
     *  @param _name the name of token to set
     *  Only the owner of the token smart contract can call this function
     *  emits a `UpdatedTokenInformation` event
     */
    function setName(string calldata _name) external;

    /**
     *  @dev sets the token symbol
     *  @param _symbol the token symbol to set
     *  Only the owner of the token smart contract can call this function
     *  emits a `UpdatedTokenInformation` event
     */
    function setSymbol(string calldata _symbol) external;

    /**
     *  @dev sets the onchain ID of the token
     *  @param _onchainID the address of the onchain ID to set
     *  Only the owner of the token smart contract can call this function
     *  emits a `UpdatedTokenInformation` event
     */
    function setOnchainID(address _onchainID) external;

    /**
     *  @dev pauses the token contract, when contract is paused investors cannot transfer tokens anymore
     *  This function can only be called by a wallet set as agent of the token
     *  emits a `Paused` event
     */
    function pause() external;

    /**
     *  @dev unpauses the token contract, when contract is unpaused investors can transfer tokens
     *  if their wallet is not blocked & if the amount to transfer is <= to the amount of free tokens
     *  This function can only be called by a wallet set as agent of the token
     *  emits an `Unpaused` event
     */
    function unpause() external;

    /**
     *  @dev sets an address frozen status for this token.
     *  @param _userAddress The address for which to update frozen status
     *  @param _freeze Frozen status of the address
     *  This function can only be called by a wallet set as agent of the token
     *  emits an `AddressFrozen` event
     */
    function setAddressFrozen(address _userAddress, bool _freeze) external;

    /**
     *  @dev freezes token amount specified for given address.
     *  @param _userAddress The address for which to update frozen tokens
     *  @param _amount Amount of Tokens to be frozen
     *  This function can only be called by a wallet set as agent of the token
     *  emits a `TokensFrozen` event
     */
    function freezePartialTokens(address _userAddress, uint256 _amount) external;

    /**
     *  @dev unfreezes token amount specified for given address
     *  @param _userAddress The address for which to update frozen tokens
     *  @param _amount Amount of Tokens to be unfrozen
     *  This function can only be called by a wallet set as agent of the token
     *  emits a `TokensUnfrozen` event
     */
    function unfreezePartialTokens(address _userAddress, uint256 _amount) external;

    /**
     *  @dev sets the Identity Registry for the token
     *  @param _identityRegistry the address of the Identity Registry to set
     *  Only the owner of the token smart contract can call this function
     *  emits an `IdentityRegistryAdded` event
     */
    function setIdentityRegistry(address _identityRegistry) external;

    /**
     *  @dev sets the compliance contract of the token
     *  @param _compliance the address of the compliance contract to set
     *  Only the owner of the token smart contract can call this function
     *  calls bindToken on the compliance contract
     *  emits a `ComplianceAdded` event
     */
    function setCompliance(address _compliance) external;

    /**
     *  @dev force a transfer of tokens between 2 whitelisted wallets
     *  In case the `from` address has not enough free tokens (unfrozen tokens)
     *  but has a total balance higher or equal to the `amount`
     *  the amount of frozen tokens is reduced in order to have enough free tokens
     *  to proceed the transfer, in such a case, the remaining balance on the `from`
     *  account is 100% composed of frozen tokens post-transfer.
     *  Require that the `to` address is a verified address,
     *  @param _from The address of the sender
     *  @param _to The address of the receiver
     *  @param _amount The number of tokens to transfer
     *  @return `true` if successful and revert if unsuccessful
     *  This function can only be called by a wallet set as agent of the token
     *  emits a `TokensUnfrozen` event if `_amount` is higher than the free balance of `_from`
     *  emits a `Transfer` event
     */
    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    /**
     *  @dev mint tokens on a wallet
     *  Improved version of default mint method. Tokens can be minted
     *  to an address if only it is a verified address as per the security token.
     *  @param _to Address to mint the tokens to.
     *  @param _amount Amount of tokens to mint.
     *  This function can only be called by a wallet set as agent of the token
     *  emits a `Transfer` event
     */
    function mint(address _to, uint256 _amount) external;

    /**
     *  @dev burn tokens on a wallet
     *  In case the `account` address has not enough free tokens (unfrozen tokens)
     *  but has a total balance higher or equal to the `value` amount
     *  the amount of frozen tokens is reduced in order to have enough free tokens
     *  to proceed the burn, in such a case, the remaining balance on the `account`
     *  is 100% composed of frozen tokens post-transaction.
     *  @param _userAddress Address to burn the tokens from.
     *  @param _amount Amount of tokens to burn.
     *  This function can only be called by a wallet set as agent of the token
     *  emits a `TokensUnfrozen` event if `_amount` is higher than the free balance of `_userAddress`
     *  emits a `Transfer` event
     */
    function burn(address _userAddress, uint256 _amount) external;

    /**
     *  @dev recovery function used to force transfer tokens from a
     *  lost wallet to a new wallet for an investor.
     *  @param _lostWallet the wallet that the investor lost
     *  @param _newWallet the newly provided wallet on which tokens have to be transferred
     *  @param _investorOnchainID the onchainID of the investor asking for a recovery
     *  This function can only be called by a wallet set as agent of the token
     *  emits a `TokensUnfrozen` event if there is some frozen tokens on the lost wallet if the recovery process is successful
     *  emits a `Transfer` event if the recovery process is successful
     *  emits a `RecoverySuccess` event if the recovery process is successful
     *  emits a `RecoveryFails` event if the recovery process fails
     */
    function recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) external returns (bool);

    /**
     *  @dev function allowing to issue transfers in batch
     *  Require that the msg.sender and `to` addresses are not frozen.
     *  Require that the total value should not exceed available balance.
     *  Require that the `to` addresses are all verified addresses,
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_toList.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _toList The addresses of the receivers
     *  @param _amounts The number of tokens to transfer to the corresponding receiver
     *  emits _toList.length `Transfer` events
     */
    function batchTransfer(address[] calldata _toList, uint256[] calldata _amounts) external;

    /**
     *  @dev function allowing to issue forced transfers in batch
     *  Require that `_amounts[i]` should not exceed available balance of `_fromList[i]`.
     *  Require that the `_toList` addresses are all verified addresses
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_fromList.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _fromList The addresses of the senders
     *  @param _toList The addresses of the receivers
     *  @param _amounts The number of tokens to transfer to the corresponding receiver
     *  This function can only be called by a wallet set as agent of the token
     *  emits `TokensUnfrozen` events if `_amounts[i]` is higher than the free balance of `_fromList[i]`
     *  emits _fromList.length `Transfer` events
     */
    function batchForcedTransfer(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;

    /**
     *  @dev function allowing to mint tokens in batch
     *  Require that the `_toList` addresses are all verified addresses
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_toList.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _toList The addresses of the receivers
     *  @param _amounts The number of tokens to mint to the corresponding receiver
     *  This function can only be called by a wallet set as agent of the token
     *  emits _toList.length `Transfer` events
     */
    function batchMint(address[] calldata _toList, uint256[] calldata _amounts) external;

    /**
     *  @dev function allowing to burn tokens in batch
     *  Require that the `_userAddresses` addresses are all verified addresses
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_userAddresses.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _userAddresses The addresses of the wallets concerned by the burn
     *  @param _amounts The number of tokens to burn from the corresponding wallets
     *  This function can only be called by a wallet set as agent of the token
     *  emits _userAddresses.length `Transfer` events
     */
    function batchBurn(address[] calldata _userAddresses, uint256[] calldata _amounts) external;

    /**
     *  @dev function allowing to set frozen addresses in batch
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_userAddresses.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _userAddresses The addresses for which to update frozen status
     *  @param _freeze Frozen status of the corresponding address
     *  This function can only be called by a wallet set as agent of the token
     *  emits _userAddresses.length `AddressFrozen` events
     */
    function batchSetAddressFrozen(address[] calldata _userAddresses, bool[] calldata _freeze) external;

    /**
     *  @dev function allowing to freeze tokens partially in batch
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_userAddresses.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _userAddresses The addresses on which tokens need to be frozen
     *  @param _amounts the amount of tokens to freeze on the corresponding address
     *  This function can only be called by a wallet set as agent of the token
     *  emits _userAddresses.length `TokensFrozen` events
     */
    function batchFreezePartialTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external;

    /**
     *  @dev function allowing to unfreeze tokens partially in batch
     *  IMPORTANT : THIS TRANSACTION COULD EXCEED GAS LIMIT IF `_userAddresses.length` IS TOO HIGH,
     *  USE WITH CARE OR YOU COULD LOSE TX FEES WITH AN "OUT OF GAS" TRANSACTION
     *  @param _userAddresses The addresses on which tokens need to be unfrozen
     *  @param _amounts the amount of tokens to unfreeze on the corresponding address
     *  This function can only be called by a wallet set as agent of the token
     *  emits _userAddresses.length `TokensUnfrozen` events
     */
    function batchUnfreezePartialTokens(address[] calldata _userAddresses, uint256[] calldata _amounts) external;

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 1 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * balanceOf() and transfer().
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the address of the onchainID of the token.
     * the onchainID of the token gives all the information available
     * about the token and is managed by the token issuer or his agent.
     */
    function onchainID() external view returns (address);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the TREX version of the token.
     * current version is 3.0.0
     */
    function version() external view returns (string memory);

    /**
     *  @dev Returns the Identity Registry linked to the token
     */
    function identityRegistry() external view returns (IIdentityRegistry);

    /**
     *  @dev Returns the Compliance contract linked to the token
     */
    function compliance() external view returns (IModularCompliance);

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() external view returns (bool);

    /**
     *  @dev Returns the freezing status of a wallet
     *  if isFrozen returns `true` the wallet is frozen
     *  if isFrozen returns `false` the wallet is not frozen
     *  isFrozen returning `true` doesn't mean that the balance is free, tokens could be blocked by
     *  a partial freeze or the whole token could be blocked by pause
     *  @param _userAddress the address of the wallet on which isFrozen is called
     */
    function isFrozen(address _userAddress) external view returns (bool);

    /**
     *  @dev Returns the amount of tokens that are partially frozen on a wallet
     *  the amount of frozen tokens is always <= to the total balance of the wallet
     *  @param _userAddress the address of the wallet on which getFrozenTokens is called
     */
    function getFrozenTokens(address _userAddress) external view returns (uint256);
}

// File contracts/roles/permissioning/owner/OwnerManager.sol

//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//

/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

contract OwnerManager is OwnerRoles {
    /// @dev the token that is managed by this OwnerManager Contract
    IToken public token;

    /// @dev Event emitted for each executed interaction with the compliance contract.
    ///
    /// For gas efficiency, only the interaction calldata selector (first 4
    /// bytes) is included in the event. For interactions without calldata or
    /// whose calldata is shorter than 4 bytes, the selector will be `0`.
    event ComplianceInteraction(address indexed target, bytes4 selector);

    /**
     *  @dev the constructor initiates the OwnerManager contract
     *  and sets msg.sender as owner of the contract
     *  @param _token the token managed by this OwnerManager contract
     */
    constructor(address _token) {
        token = IToken(_token);
    }

    /**
     *  @dev calls the `setIdentityRegistry` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-setIdentityRegistry}.
     *  Requires that `_onchainID` is set as RegistryAddressSetter on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callSetIdentityRegistry(address _identityRegistry, IIdentity _onchainID) external {
        require(
            isRegistryAddressSetter(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Registry Address Setter"
        );
        token.setIdentityRegistry(_identityRegistry);
    }

    /**
     *  @dev calls the `setCompliance` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-setCompliance}.
     *  Requires that `_onchainID` is set as ComplianceSetter on the OwnerManager contract
     *  Requires that msg.sender is a MANAGEMENT KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callSetCompliance(address _compliance, IIdentity _onchainID) external {
        require(
            isComplianceSetter(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Compliance Setter"
        );
        token.setCompliance(_compliance);
    }

    /**
     *  @dev calls any onlyOwner function available on the compliance contract
     *  OwnerManager has to be set as owner on the compliance smart contract to process this function
     *  Requires that `_onchainID` is set as ComplianceManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callComplianceFunction(bytes calldata callData, IIdentity _onchainID) external {
        require(
            isComplianceManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Compliance Manager");
        address target = address(token.compliance());

        // NOTE: Use assembly to call the interaction instead of a low level
        // call for two reasons:
        // - We don't want to copy the return data, since we discard it for
        // interactions.
        // - Solidity will under certain conditions generate code to copy input
        // calldata twice to memory (the second being a "memcopy loop").
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let freeMemoryPointer := mload(0x40)
            calldatacopy(freeMemoryPointer, callData.offset, callData.length)
            if iszero(
                call(
                    gas(),
                    target,
                    0,
                    freeMemoryPointer,
                    callData.length,
                    0,
                    0
                    ))
                {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }

        emit ComplianceInteraction(target, _selector(callData));

        }

    /**
     *  @dev calls the `setName` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-setName}.
     *  Requires that `_onchainID` is set as TokenInfoManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callSetTokenName(string calldata _name, IIdentity _onchainID) external {
        require(
            isTokenInfoManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Token Information Manager"
        );
        token.setName(_name);
    }

    /**
     *  @dev calls the `setSymbol` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-setSymbol}.
     *  Requires that `_onchainID` is set as TokenInfoManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callSetTokenSymbol(string calldata _symbol, IIdentity _onchainID) external {
        require(
            isTokenInfoManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Token Information Manager"
        );
        token.setSymbol(_symbol);
    }

    /**
     *  @dev calls the `setOnchainID` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-setOnchainID}.
     *  Requires that `_tokenOnchainID` is set as TokenInfoManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callSetTokenOnchainID(address _tokenOnchainID, IIdentity _onchainID) external {
        require(
            isTokenInfoManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Token Information Manager"
        );
        token.setOnchainID(_tokenOnchainID);
    }

    /**
     *  @dev calls the `setClaimTopicsRegistry` function on the Identity Registry contract
     *  OwnerManager has to be set as owner on the Identity Registry smart contract to process this function
     *  See {IIdentityRegistry-setClaimTopicsRegistry}.
     *  Requires that `_onchainID` is set as RegistryAddressSetter on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callSetClaimTopicsRegistry(address _claimTopicsRegistry, IIdentity _onchainID) external {
        require(
            isRegistryAddressSetter(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Registry Address Setter"
        );
        token.identityRegistry().setClaimTopicsRegistry(_claimTopicsRegistry);
    }

    /**
     *  @dev calls the `setTrustedIssuersRegistry` function on the Identity Registry contract
     *  OwnerManager has to be set as owner on the Identity Registry smart contract to process this function
     *  See {IIdentityRegistry-setTrustedIssuersRegistry}.
     *  Requires that `_onchainID` is set as RegistryAddressSetter on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callSetTrustedIssuersRegistry(address _trustedIssuersRegistry, IIdentity _onchainID) external {
        require(
            isRegistryAddressSetter(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT Registry Address Setter"
        );
        token.identityRegistry().setTrustedIssuersRegistry(_trustedIssuersRegistry);
    }

    /**
     *  @dev calls the `addTrustedIssuer` function on the Trusted Issuers Registry contract
     *  OwnerManager has to be set as owner on the Trusted Issuers Registry smart contract to process this function
     *  See {ITrustedIssuersRegistry-addTrustedIssuer}.
     *  Requires that `_onchainID` is set as IssuersRegistryManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callAddTrustedIssuer(
        IClaimIssuer _trustedIssuer,
        uint256[] calldata _claimTopics,
        IIdentity _onchainID
    ) external {
        require(
            isIssuersRegistryManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT IssuersRegistryManager"
        );
        token.identityRegistry().issuersRegistry().addTrustedIssuer(_trustedIssuer, _claimTopics);
    }

    /**
     *  @dev calls the `removeTrustedIssuer` function on the Trusted Issuers Registry contract
     *  OwnerManager has to be set as owner on the Trusted Issuers Registry smart contract to process this function
     *  See {ITrustedIssuersRegistry-removeTrustedIssuer}.
     *  Requires that `_onchainID` is set as IssuersRegistryManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callRemoveTrustedIssuer(IClaimIssuer _trustedIssuer, IIdentity _onchainID) external {
        require(
            isIssuersRegistryManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT IssuersRegistryManager"
        );
        token.identityRegistry().issuersRegistry().removeTrustedIssuer(_trustedIssuer);
    }

    /**
     *  @dev calls the `updateIssuerClaimTopics` function on the Trusted Issuers Registry contract
     *  OwnerManager has to be set as owner on the Trusted Issuers Registry smart contract to process this function
     *  See {ITrustedIssuersRegistry-updateIssuerClaimTopics}.
     *  Requires that `_onchainID` is set as IssuersRegistryManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callUpdateIssuerClaimTopics(
        IClaimIssuer _trustedIssuer,
        uint256[] calldata _claimTopics,
        IIdentity _onchainID
    ) external {
        require(
            isIssuersRegistryManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT IssuersRegistryManager"
        );
        token.identityRegistry().issuersRegistry().updateIssuerClaimTopics(_trustedIssuer, _claimTopics);
    }

    /**
     *  @dev calls the `addClaimTopic` function on the Claim Topics Registry contract
     *  OwnerManager has to be set as owner on the Claim Topics Registry smart contract to process this function
     *  See {IClaimTopicsRegistry-addClaimTopic}.
     *  Requires that `_onchainID` is set as ClaimRegistryManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callAddClaimTopic(uint256 _claimTopic, IIdentity _onchainID) external {
        require(
            isClaimRegistryManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT ClaimRegistryManager"
        );
        token.identityRegistry().topicsRegistry().addClaimTopic(_claimTopic);
    }

    /**
     *  @dev calls the `removeClaimTopic` function on the Claim Topics Registry contract
     *  OwnerManager has to be set as owner on the Claim Topics Registry smart contract to process this function
     *  See {IClaimTopicsRegistry-removeClaimTopic}.
     *  Requires that `_onchainID` is set as ClaimRegistryManager on the OwnerManager contract
     *  Requires that msg.sender is an ACTION KEY on `_onchainID`
     *  @param _onchainID the _onchainID contract of the caller, e.g. "i call this function and i am Bob"
     */
    function callRemoveClaimTopic(uint256 _claimTopic, IIdentity _onchainID) external {
        require(
            isClaimRegistryManager(address(_onchainID)) && _onchainID.keyHasPurpose(keccak256(abi.encode(msg.sender)), 2),
            "Role: Sender is NOT ClaimRegistryManager"
        );
        token.identityRegistry().topicsRegistry().removeClaimTopic(_claimTopic);
    }

    /**
     *  @dev calls the `transferOwnershipOnTokenContract` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-transferOwnershipOnTokenContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callTransferOwnershipOnTokenContract(address _newOwner) external onlyAdmin {
        Ownable(address(token)).transferOwnership(_newOwner);
    }

    /**
     *  @dev calls the `transferOwnershipOnIdentityRegistryContract` function on the Identity Registry contract
     *  OwnerManager has to be set as owner on the Identity Registry smart contract to process this function
     *  See {IIdentityRegistry-transferOwnershipOnIdentityRegistryContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callTransferOwnershipOnIdentityRegistryContract(address _newOwner) external onlyAdmin {
        Ownable(address(token.identityRegistry())).transferOwnership(_newOwner);
    }

    /**
     *  @dev calls the `transferOwnershipOnComplianceContract` function on the Compliance contract
     *  OwnerManager has to be set as owner on the Compliance smart contract to process this function
     *  See {ICompliance-transferOwnershipOnComplianceContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callTransferOwnershipOnComplianceContract(address _newOwner) external onlyAdmin {
        Ownable(address(token.compliance())).transferOwnership(_newOwner);
    }

    /**
     *  @dev calls the `transferOwnershipOnClaimTopicsRegistryContract` function on the Claim Topics Registry contract
     *  OwnerManager has to be set as owner on the Claim Topics registry smart contract to process this function
     *  See {IClaimTopicsRegistry-transferOwnershipOnClaimTopicsRegistryContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callTransferOwnershipOnClaimTopicsRegistryContract(address _newOwner) external onlyAdmin {
        Ownable(address(token.identityRegistry().topicsRegistry())).transferOwnership(_newOwner);
    }

    /**
     *  @dev calls the `transferOwnershipOnIssuersRegistryContract` function on the Trusted Issuers Registry contract
     *  OwnerManager has to be set as owner on the Trusted Issuers registry smart contract to process this function
     *  See {ITrustedIssuersRegistry-transferOwnershipOnIssuersRegistryContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callTransferOwnershipOnIssuersRegistryContract(address _newOwner) external onlyAdmin {
        Ownable(address(token.identityRegistry().issuersRegistry())).transferOwnership(_newOwner);
    }

    /**
     *  @dev calls the `addAgentOnTokenContract` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-addAgentOnTokenContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callAddAgentOnTokenContract(address _agent) external onlyAdmin {
        AgentRole(address(token)).addAgent(_agent);
    }

    /**
     *  @dev calls the `removeAgentOnTokenContract` function on the token contract
     *  OwnerManager has to be set as owner on the token smart contract to process this function
     *  See {IToken-removeAgentOnTokenContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callRemoveAgentOnTokenContract(address _agent) external onlyAdmin {
        AgentRole(address(token)).removeAgent(_agent);
    }

    /**
     *  @dev calls the `addAgentOnIdentityRegistryContract` function on the Identity Registry contract
     *  OwnerManager has to be set as owner on the Identity Registry smart contract to process this function
     *  See {IIdentityRegistry-addAgentOnIdentityRegistryContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callAddAgentOnIdentityRegistryContract(address _agent) external onlyAdmin {
        AgentRole(address(token.identityRegistry())).addAgent(_agent);
    }

    /**
     *  @dev calls the `removeAgentOnIdentityRegistryContract` function on the Identity Registry contract
     *  OwnerManager has to be set as owner on the Identity Registry smart contract to process this function
     *  See {IIdentityRegistry-removeAgentOnIdentityRegistryContract}.
     *  Requires that msg.sender is an Admin of the OwnerManager contract
     */
    function callRemoveAgentOnIdentityRegistryContract(address _agent) external onlyAdmin {
        AgentRole(address(token.identityRegistry())).removeAgent(_agent);
    }

    /// @dev Extracts the Solidity ABI selector for the specified interaction.
    /// @param callData Interaction data.
    /// @return result The 4 byte function selector of the call encoded in
    /// this interaction.
    function _selector(bytes calldata callData) internal pure returns (bytes4 result) {
        if (callData.length >= 4) {
            // NOTE: Read the first word of the interaction's calldata. The
            // value does not need to be shifted since `bytesN` values are left
            // aligned, and the value does not need to be masked since masking
            // occurs when the value is accessed and not stored:
            // <https://docs.soliditylang.org/en/v0.7.6/abi-spec.html#encoding-of-indexed-event-parameters>
            // <https://docs.soliditylang.org/en/v0.7.6/assembly.html#access-to-external-variables-functions-and-libraries>
            // solhint-disable-next-line no-inline-assembly
            assembly {
                result := calldataload(callData.offset)
            }
        }
    }
}
