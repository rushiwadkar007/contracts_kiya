// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenizationRoleManager {
    struct RoleRequest {
        string name;
        string email;
        uint256 userId;
        address requester;
        string roleType;
        bool approved;
        bool rejected;
        uint256 approvalCount;
        uint256 rejectionCount;
        uint256 voteCount;
        string userDetails;
    }
    struct AdminRequest {
        uint256 requestID;
        string losBankID;
        uint256 bankID;
        address requester;
        string roleType;
        bool approved;
        bool rejected;
        uint256 approvalCount;
        uint256 rejectionCount;
        uint256 voteCount;
        bool allVoted;
        string adminDetails;
    }
    struct RegulatorRequest {
        string ID;
        address requester;
        string roleType;
        uint256 NetworkId;
        address nodeAddress;
        bool approved;
    }
    struct Banks {
        uint256 ID;
        string losBankID;
        address requester;
        uint256 NetworkId;
        bool isApproved;
        bool isRejected;
        uint256 approvalCount;
        string bankDetails;
        uint256 voteCount;
        bool allVoted;
    }
    function changeVoteParams(uint256 _requiredVoteCount, uint256 _requiredApprovals) external returns(bool);
    function reqBankRole(string memory losBankID, string memory NetworkId,string memory bankDetails) external;
    function getBankReqs (uint256 bankID) external returns (Banks memory);
    function bankAdmReqs(string memory _losBankID, string memory _admID) external returns (AdminRequest memory);
    function getBankApps(string memory id)  external returns (address[] memory);
    function apprBankReq(string memory bankID) external;
    function getBankApprovalStatus(address _bankWalletAddress) external  returns(bool);
    function rejectBankReq(string memory Id) external;
    function reqBankAdmin(string memory roleType,string memory _losBankID,string memory bankID,string memory adminDetails) external;
    function appBankAdm(string memory bankID,string memory _losBankID,string memory _id,string memory _totalApprovedAdmins, address requester) external;
    function rejectBankAdm(uint256 bankID,string memory _losBankID,uint256 id,uint256 totalApprovedAdmins, address requester) external;
    function getAdmReqs(string memory _losBankId, uint256 bankID) external returns (AdminRequest memory);
    function requestUserRole(string memory _losBankID,string memory roleType,string memory _name, string memory userDetails, string memory email) external;
    function approveUserRoleRequest(string memory _losBankID,uint256 _userId,uint256 totalApprovedAdmins, address requester, string memory email) external;
    function rejectUserRoleRequest(string memory _losBankID,uint256 _userId, string memory _totalApprovedAdmins, address requester, string memory email) external;
    function getUserRequests(string memory _losBankID) external view returns (uint256);
    function isUserApproved(string memory _losBankID, uint256 _userID) external view returns(bool);
    function isAdminApproved(string memory _losBankID, uint256 _userID) external view returns(bool);
    function getAdmin(string memory _losBankID, address _walletAddress) external view returns(AdminRequest memory);
    function getUser(string memory _losBankID, address _walletAddress) external view returns(RoleRequest memory);
    function getUserRoleRequestApprovers(string memory _losBankID, uint256 userRequestID) external view returns(string[] memory);
    function getUserRoleRequestRejectors(string memory _losBankID, uint256 userRequestID) external view returns(string[] memory);
}