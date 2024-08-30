
// File: contracts/ITokenizationRoleManager.sol


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
// File: contracts/TokenizationRoleManager.sol


pragma solidity ^0.8.0;

//import "./iRoleApprover.sol";

contract TokenizationRoleManager is ITokenizationRoleManager{
    uint256 public RequestCounter;
    //iRoleApprover public roleApprover;
    //address public regulator;
    mapping(address => bool) public bankAdmins;
    mapping(address => bool) public regulators;
    mapping(address => bool) public approvedBanks;
    mapping(uint256 => Banks) public BankDetails;
    mapping(address => Banks) public BankDetailsByOwner;
    mapping(string => mapping(uint256 => AdminRequest)) public adminRequests;
    mapping(string => mapping(address => AdminRequest)) bankAdminReqs;
    mapping(string => mapping(address => RoleRequest)) bankUserReqs;
    mapping(string => mapping(uint256 => uint256)) public tBankAdmReqs;
    mapping(string => mapping(uint256 => mapping(uint256 => address)))
        public bAdminApprs;
    // losBankID => bankID => adminReqID
    // struct RoleRequest {
    //     string name;
    //     uint256 userId;
    //     address requester;
    //     string roleType;
    //     bool approved;
    //     uint256 approvalCount;
    //     bool rejectedByAdmin;
    //     string userDetails;
    // }

    // struct AdminRequest {
    //     uint256 requestID;
    //     string losBankID;
    //     uint256 bankID;
    //     address requester;
    //     string roleType;
    //     bool approved;
    //     bool rejected;
    //     uint256 approvalCount;
    //     uint256 rejectionCount;
    //     uint256 voteCount;
    //     bool allVoted;
    //     string adminDetails;
    // }

    // struct RegulatorRequest {
    //     string ID;
    //     address requester;
    //     string roleType;
    //     uint256 NetworkId;
    //     address nodeAddress;
    //     bool approved;
    // }
    // //hash: bankID, groupOfficeID, moduleName, moduleID, bankEmail, nodeAddress, bankName, bankMerkleRoot
    // struct Banks {
    //     uint256 ID;
    //     string losBankID;
    //     address requester;
    //     uint256 NetworkId;
    //     bool isApproved;
    //     bool isRejected;
    //     uint256 approvalCount;
    //     string bankDetails;
    //     uint256 voteCount;
    //     bool allVoted;
    // }
    // RoleRequest[] public userRoleRequests;
    mapping(string => mapping(uint256 => RoleRequest)) public userRoleRequests;
    mapping(string => uint256) public totalUserRoleRequests;
    RegulatorRequest[] public regRequests;
    uint256 public bnkReqs;
    mapping(uint256 => uint256) public bnkAdmReqs;
    // uint256 public bnkAdmReqs;
    event RoleMakerDeployment(
        string contractName,
        address owner,
        uint256 deploymentTime
    );
    event RoleRequested(
        address indexed requester,
        string roleType,
        string name,
        uint256 userId
    );
    event RoleApproved(uint256 indexed id);
    event AdminRequested(address indexed requester, string roleType);
    event RegulatorRequested(
        address indexed requester,
        string[] ID,
        string roleType
    );
    event AdminApproved(uint256 id);
    event RoleRequestRejected(
        uint256 indexed id,
        address requester,
        string roleType
    );
    event BankAdminRequestRejected(
        uint256 indexed id,
        address requester,
        string roleType
    );
    event BankRequestRejected(
        uint256 indexed ID,
        address requester,
        string BankName
    );

    modifier onlyRegulator() {
        require(
            regulators[msg.sender],
            "Only regulator can perform this action"
        );
        _;
    }

    modifier onlyBank() {
        require(
            approvedBanks[msg.sender] == true || bankAdmins[msg.sender] == true,
            "Only Bank can perform this action"
        );
        _;
    }

    modifier onlyBankOrRegulator() {
        require(
            regulators[msg.sender] || approvedBanks[msg.sender],
            "Only bank or regulator can perform this action"
        );
        _;
    }

    modifier onlyBankAdmin() {
        require(
            bankAdmins[msg.sender],
            "Only bank admin can perform this action"
        );
        _;
    }

    modifier validateRequirement(
        uint256 verifierCount,
        uint256 _requiredVoteCount
    ) {
        require(
            verifierCount >= 1 ||
                _requiredVoteCount > verifierCount ||
                _requiredVoteCount == 0 ||
                verifierCount == 0,
            "Invalid Verifier Condition"
        );
        _;
    }

    address[] public regVerifiers;
    uint256 public requiredVoteCount;
    mapping(address => bool) private isRBIVerifier;
    mapping(uint256 => mapping(address => bool)) approvals;
    address private owner;
    uint256 public requiredApprovals;

    constructor(
        address[] memory _regulatorVerifiers,
        uint256 _requiredVoteCount,
        uint256 _requiredApprovals,
        string[] memory _regIDs,
        address nodeAddress
    ) {
        owner = msg.sender;
        regVerifiers = _regulatorVerifiers;
        require(msg.sender == nodeAddress, "invalid regulator Node");
        reqRegulator("Regulator", _regIDs, "99", nodeAddress);
        requiredVoteCount = _requiredVoteCount;
        requiredApprovals = _requiredApprovals;
        emit RoleMakerDeployment("RoleMaker", msg.sender, block.timestamp);
        emit RegulatorRequested(msg.sender, _regIDs, "Regulator");
    }

    function stringToUint256(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function changeVoteParams(
        uint256 _requiredVoteCount,
        uint256 _requiredApprovals
    ) external onlyRegulator returns (bool changed) {
        requiredApprovals = _requiredApprovals;
        requiredVoteCount = _requiredVoteCount;
        changed = true;
        return changed;
    }

    // constructor(address _roleApprover) {
    //     roleApprover = iRoleApprover(_roleApprover);
    //     Bank = msg.sender;
    // }
    function reqBankRole(
        string memory losBankID,
        string memory NetworkId,
        string memory bankDetails
    ) external {
        require(owner != msg.sender, "KIYA can not belong to the Regulator!");
        uint256 _NetworkId = stringToUint256(NetworkId);
        bnkReqs++;
        //losBankID
        for (uint256 i = 1; i <= bnkReqs; i++) {
            require(
                keccak256(abi.encodePacked(BankDetails[i].bankDetails)) !=
                    keccak256(abi.encodePacked(bankDetails)) || BankDetails[i].isRejected == true && BankDetails[i].isApproved == false,
                "PAST REQUESTS PENDING OR DIFFERENT BANK APPLICATION OR BANK HAS ALREADY BEEN APPROVED!"
            );
        }
        require(
            isRBIVerifier[msg.sender] == false,
            "Regulator Verifiers cannot request a role"
        );
        // require(
        //     BankDetails[bnkReqs].requester != address(0x0) &&  BankDetails[bnkReqs].requester != msg.sender &&
        //         BankDetails[bnkReqs].isApproved == true,
        //     "This Bank Account is already approved!"
        // );
        require(
            !regulators[msg.sender],
            "Regulators cannot request a user role"
        );
        require(
            !bankAdmins[msg.sender],
            "Bankadmins cannot request a user role"
        );
        // Check if user already has a pending request for the same role type or customer ID
        require(
            keccak256(abi.encodePacked(BankDetails[bnkReqs].bankDetails)) !=
                keccak256(abi.encodePacked(bankDetails)),
            "Same Details are already present"
        );
        require(
            BankDetails[bnkReqs].requester != msg.sender ||
                BankDetails[bnkReqs].isRejected == true,
            "User already has a pending request for this role type"
        );
        require(BankDetails[bnkReqs].ID != bnkReqs, "Bank ID already exists");
        Banks memory b = Banks(
            bnkReqs,
            losBankID,
            msg.sender,
            _NetworkId,
            false,
            false,
            0,
            bankDetails,
            0,
            false
        );
        BankDetails[bnkReqs] = b;
        BankDetailsByOwner[msg.sender] = b;
    }

    function reqRegulator(
        string memory roleType,
        string[] memory _IDs,
        string memory NetworkId,
        address _nodeAddress
    ) internal {
        require(
            isRBIVerifier[msg.sender] == false,
            "owner cannot request a role"
        );
        require(
            keccak256(bytes(roleType)) == keccak256("Regulator"),
            "Invalid role request type"
        );
        require(bytes(roleType).length > 0, "Role type cannot be empty");
        uint256 _NetworkId = stringToUint256(NetworkId);
        // Check if user already has a pending request for the same role type or ID
        RegulatorRequest memory newRequest;
        for (uint256 i = 0; i < regVerifiers.length; i++) {
            newRequest = RegulatorRequest(
                _IDs[i],
                regVerifiers[i],
                roleType,
                _NetworkId,
                _nodeAddress,
                true
            );
            regulators[regVerifiers[i]] = true;
            isRBIVerifier[regVerifiers[i]] = true;
            regRequests.push(newRequest);
        }
    }

    function getBankReqs(uint256 bankID)
        external
        view
        onlyRegulator
        returns (Banks memory)
    {
        return BankDetails[bankID];
    }

    function bankAdmReqs(string memory _losBankID, string memory _admID)
        external
        view
        onlyBank
        returns (AdminRequest memory)
    {
        uint256 admID = stringToUint256(_admID);
        return adminRequests[_losBankID][admID];
    }

    function getBankApps(string memory id)
        external
        view
        onlyBankOrRegulator
        returns (address[] memory)
    {
        uint256 _id = stringToUint256(id);
        address[] memory approvers = getRegDetails();
        address[] memory approversList = new address[](3);
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvals[_id][approvers[i]]) {
                approversList[i] = approvers[i];
            }
        }
        return approversList;
    }

    function getRegDetails() internal view returns (address[] memory) {
        return regVerifiers;
    }

    function apprBankReq(string memory bankID) external onlyRegulator {
        require(regulators[msg.sender] == true, "Regulator Access Not Given!");
        uint256 _Id = stringToUint256(bankID);
        bnkAdmReqs[BankDetails[_Id].ID] = 1;
        bool found = false;
        // Iterate through role requests to find the request with the provided customer ID
        if (BankDetails[_Id].ID == _Id) {
            require(!BankDetails[_Id].isApproved, "Request already approved");
            require(
                !approvals[BankDetails[_Id].ID][msg.sender],
                "Already approved by this bank admin"
            );
            approvals[BankDetails[_Id].ID][msg.sender] = true;
            BankDetails[_Id].approvalCount++;
            BankDetailsByOwner[BankDetails[_Id].requester].approvalCount++;
            BankDetails[_Id].voteCount++;
            BankDetailsByOwner[BankDetails[_Id].requester].voteCount++;
            // if (
            //     BankDetails[_Id].approvalCount <= requiredApprovals &&
            //     BankDetails[_Id].voteCount == requiredVoteCount
            // ) {
                BankDetails[_Id].isApproved = true;
                BankDetailsByOwner[BankDetails[_Id].requester].isApproved = true;
                BankDetails[_Id].isRejected = false;
                BankDetailsByOwner[BankDetails[_Id].requester].isRejected = false;
                approvedBanks[BankDetails[_Id].requester] = true;
                BankDetails[_Id].allVoted = true;
                BankDetailsByOwner[BankDetails[_Id].requester].allVoted = true;
                AdminRequest storage newRequest = adminRequests[
                    BankDetails[_Id].losBankID
                ][bnkAdmReqs[BankDetails[_Id].ID]]; //needs to be reviewed
                newRequest.requester = BankDetails[_Id].requester;
                newRequest.losBankID = BankDetails[_Id].losBankID;
                newRequest.bankID = BankDetails[_Id].ID;
                newRequest.requestID = bnkAdmReqs[BankDetails[_Id].ID];
                newRequest.roleType = "Admin";
                newRequest.approved = true;
                newRequest.rejected = false;
                newRequest.approvalCount = BankDetails[_Id].approvalCount;
                newRequest.voteCount = BankDetails[_Id].voteCount;
                newRequest.allVoted = true;
                newRequest.adminDetails = BankDetails[_Id].bankDetails;
                bankAdminReqs[BankDetails[_Id].losBankID][
                    BankDetails[_Id].requester
                ] = newRequest;
                bankAdmins[BankDetails[_Id].requester] = true;
            // }
            // else{
            //     revert("All Regulators Should have to be voted for final Mandate!");
            // }

            found = true;
        }

        require(found, "No role request found for the provided ID");
    }

    function getBankApprovalStatus(address _bankWalletAddress) public view returns(bool){
        return approvedBanks[_bankWalletAddress];
    }

    function rejectBankReq(string memory Id)
        external
        onlyRegulator
    {
        uint256 _Id = stringToUint256(Id);
        // Iterate through role requests to find the request with the provided customer ID
        if (BankDetails[_Id].ID == _Id) {
            require(!BankDetails[_Id].isApproved, "Request already approved");
            BankDetails[_Id].voteCount++;
            // if (
            //     BankDetails[_Id].voteCount == requiredVoteCount &&
            //     BankDetails[_Id].approvalCount < requiredApprovals
            // ) {
                BankDetails[_Id].isApproved = false;
                BankDetailsByOwner[BankDetails[_Id].requester].isApproved = false;
                BankDetails[_Id].isRejected = true;
                BankDetailsByOwner[BankDetails[_Id].requester].isRejected = true;
                BankDetails[_Id].allVoted = true;
                BankDetailsByOwner[BankDetails[_Id].requester].allVoted = true;
            // }
            emit BankRequestRejected(
                BankDetails[_Id].ID,
                BankDetails[_Id].requester,
                BankDetails[_Id].losBankID
            );
            return;
        }
        // If no request is found for the provided customer ID, revert
        revert("No role request found for the provided customer ID");
    }

    mapping(address => mapping(string => bool)) hasAlreadysentBAdmRequest;
    mapping(address => mapping(string => bool)) isApprovedBAdmRequest;
    mapping(address => mapping(string => bool)) isRejectedBAdmRequest;
    mapping(string =>  mapping(uint256 => string[])) public userRequestApprovers;
    mapping(string => mapping(uint256 => string[])) public userRequestRejectors;
    mapping(address => mapping(string => mapping(uint256 => bool))) private hasAdminApprovedRejectedUserReq;
    function reqBankAdmin(
        string memory roleType,
        string memory _losBankID,
        string memory bankID,
        string memory adminDetails
    ) external {
        uint256 _bankID = stringToUint256(bankID);
        bnkAdmReqs[_bankID]++;
        for (uint256 i = 1; i <= bnkAdmReqs[_bankID]; i++) {
            require(
                adminRequests[_losBankID][i].requester != msg.sender ||
                    adminRequests[_losBankID][i].rejected == true,
                "Admin Request Already Sent by This User!"
            );
        }
        require(owner != msg.sender, "Owner can not be from the bank!");
        require(
            isApprovedBAdmRequest[msg.sender][_losBankID] == false,
            "User has already been Approved!"
        );
        require(
            isRejectedBAdmRequest[msg.sender][_losBankID] == false,
            "User has already been Rejected!"
        );
        require(
            hasAlreadysentBAdmRequest[msg.sender][_losBankID] == false,
            "Request Already Sent"
        );

        require(
            isRBIVerifier[msg.sender] == false,
            "Regulator cannot request a role"
        );
        require(
            !regulators[msg.sender],
            "Regulators cannot request a admin role"
        );
        require(
            keccak256(bytes(roleType)) == keccak256("Admin"),
            "Invalid role request type"
        );
        require(bytes(roleType).length > 0, "Role type cannot be empty");
        // Check if user already has a pending request for the same role type
        require(
            adminRequests[_losBankID][bnkAdmReqs[_bankID]].requester !=
                msg.sender ||
                keccak256(
                    bytes(
                        adminRequests[_losBankID][bnkAdmReqs[_bankID]].roleType
                    )
                ) !=
                keccak256(bytes(roleType)),
            "User already has a pending request for this role type"
        );
        AdminRequest storage newRequest = adminRequests[_losBankID][
            bnkAdmReqs[_bankID]
        ];
        newRequest.requester = msg.sender;
        newRequest.losBankID = _losBankID;
        newRequest.bankID = _bankID;
        newRequest.requestID = bnkAdmReqs[_bankID];
        newRequest.roleType = roleType;
        newRequest.approved = false;
        newRequest.rejected = false;
        newRequest.approvalCount = 0;
        newRequest.rejectionCount = 0;
        newRequest.voteCount = 0;
        newRequest.allVoted = false;
        newRequest.adminDetails = adminDetails;
        bankAdminReqs[_losBankID][msg.sender] = newRequest;
        hasAlreadysentBAdmRequest[msg.sender][_losBankID] = true;
        emit AdminRequested(msg.sender, roleType);
    }

    mapping(address => mapping(string => mapping(uint256 => bool))) isBAdminVoted;

    function appBankAdm(
        string memory bankID,
        string memory _losBankID,
        string memory _id,
        string memory _totalApprovedAdmins,
        address requester
    ) external onlyBank {
        uint256 _bankID = stringToUint256(bankID);
        uint256 id = stringToUint256(_id);
        uint256 totalApprovedAdmins = stringToUint256(_totalApprovedAdmins);
        require(
            isApprovedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] == false,
            "User has already been Approved!"
        );
        require(
            isBAdminVoted[msg.sender][_losBankID][id] == false,
            "Already Voted"
        );
        require(
            adminRequests[_losBankID][id].requester != address(0x0) &&
                adminRequests[_losBankID][id].requestID != 0,
            "Request Doesn't Exist!"
        );
        tBankAdmReqs[_losBankID][_bankID]++;
        uint256 _requiredApprovals = totalApprovedAdmins / 2;
        require(
            adminRequests[_losBankID][id].approved == false &&
                adminRequests[_losBankID][id].rejected == false,
            "Admin Request Already Approved!"
        );
        require(
            keccak256(abi.encodePacked(BankDetails[_bankID].losBankID)) ==
                keccak256(abi.encodePacked(_losBankID)),
            "Invalid Bank"
        );
        require(
            !adminRequests[_losBankID][id].approved,
            "Bank Admin Request already approved!"
        );
        require(
            bAdminApprs[_losBankID][_bankID][id] != msg.sender,
            "Request is Already Approved by This Admin!"
        );
        adminRequests[_losBankID][id].approvalCount++;
        adminRequests[_losBankID][id].voteCount++;
        bankAdminReqs[_losBankID][requester].approvalCount++;
        bankAdminReqs[_losBankID][requester].voteCount++;
        isBAdminVoted[msg.sender][_losBankID][id] = true;
        if (
            totalApprovedAdmins < 3 &&
            adminRequests[_losBankID][id].approved == false
        ) {
            adminRequests[_losBankID][id].approved = true;
            adminRequests[_losBankID][id].rejected = false;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = true;
            bankAdminReqs[_losBankID][requester].rejected = false;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            bankAdmins[adminRequests[_losBankID][id].requester] = true;
            bAdminApprs[_losBankID][id][tBankAdmReqs[_losBankID][id]] = msg
                .sender;
            isApprovedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] = true;
            emit AdminApproved(id);
        } else if (
            adminRequests[_losBankID][id].approvalCount >=
            _requiredApprovals + 1 &&
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins &&
            adminRequests[_losBankID][id].approvalCount >=
            _requiredApprovals + 1
        ) {
            adminRequests[_losBankID][id].approved = true;
            adminRequests[_losBankID][id].rejected = false;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = true;
            bankAdminReqs[_losBankID][requester].rejected = false;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            isApprovedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] = true;
            bankAdmins[adminRequests[_losBankID][id].requester] = true;
            bAdminApprs[_losBankID][id][tBankAdmReqs[_losBankID][id]] = msg
                .sender;
            emit AdminApproved(id);
        } else if (
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins &&
            adminRequests[_losBankID][id].approvalCount >=
            _requiredApprovals + 1
        ) {
            adminRequests[_losBankID][id].approved = true;
            adminRequests[_losBankID][id].rejected = false;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = true;
            bankAdminReqs[_losBankID][requester].rejected = false;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            isApprovedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] = true;
            bankAdmins[adminRequests[_losBankID][id].requester] = true;
            bAdminApprs[_losBankID][id][tBankAdmReqs[_losBankID][id]] = msg
                .sender;
        } else if (
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins &&
            adminRequests[_losBankID][id].approvalCount ==
            adminRequests[_losBankID][id].rejectionCount
        ) {
            revert(
                "Equal Voting Scenario Asks for One more Admin Vote, Please Vote in favour of Rejection to get Final Decision!"
            );
            // emit AdminApproved(id);
        } else if (
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins
        ) {
            adminRequests[_losBankID][id].approved = true;
            adminRequests[_losBankID][id].rejected = false;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = true;
            bankAdminReqs[_losBankID][requester].rejected = false;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            emit AdminApproved(id);
        } else {
            bankAdmins[adminRequests[_losBankID][id].requester] = true;
            bAdminApprs[_losBankID][id][tBankAdmReqs[_losBankID][id]] = msg
                .sender;
        }
    }

    function rejectBankAdm(
        uint256 bankID,
        string memory _losBankID,
        uint256 id,
        uint256 totalApprovedAdmins,
        address requester
    ) external onlyBank {
        require(
            isRejectedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] == false,
            "User has already been Rejected!"
        );
        require(
            isBAdminVoted[msg.sender][_losBankID][id] == false,
            "Already Voted"
        );
        uint256 _requiredApprovals = totalApprovedAdmins / 2;
        require(
            keccak256(abi.encodePacked(BankDetails[bankID].losBankID)) ==
                keccak256(abi.encodePacked(_losBankID)),
            "Invalid Bank"
        );
        require(
            !adminRequests[_losBankID][id].approved,
            "Request already approved"
        );
        adminRequests[_losBankID][id].rejectionCount++;
        adminRequests[_losBankID][id].voteCount++;
        bankAdminReqs[_losBankID][requester].rejectionCount++;
        bankAdminReqs[_losBankID][requester].voteCount++;
        isBAdminVoted[msg.sender][_losBankID][id] = true;
        // if (adminRequests[_losBankID][id].rejectionCount >= _requiredApprovals +1) {
        //     isRejectedBAdmRequest[adminRequests[_losBankID][id].requester][
        //         _losBankID
        //     ] = true;
        // }
        if (
            totalApprovedAdmins < 3 &&
            adminRequests[_losBankID][id].rejected == false
        ) {
            adminRequests[_losBankID][id].approved = false;
            adminRequests[_losBankID][id].rejected = true;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = false;
            bankAdminReqs[_losBankID][requester].rejected = true;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            isRejectedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] = true;
            emit AdminApproved(id);
        } else if (
            adminRequests[_losBankID][id].rejectionCount >=
            _requiredApprovals + 1 &&
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins &&
            adminRequests[_losBankID][id].rejectionCount >=
            _requiredApprovals + 1
        ) {
            adminRequests[_losBankID][id].approved = false;
            adminRequests[_losBankID][id].rejected = true;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = false;
            bankAdminReqs[_losBankID][requester].rejected = true;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            isRejectedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] = true;
            emit AdminApproved(id);
        } else if (
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins &&
            adminRequests[_losBankID][id].rejectionCount >=
            _requiredApprovals + 1
        ) {
            adminRequests[_losBankID][id].approved = true;
            adminRequests[_losBankID][id].rejected = false;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = true;
            bankAdminReqs[_losBankID][requester].rejected = false;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            isRejectedBAdmRequest[adminRequests[_losBankID][id].requester][
                _losBankID
            ] = true;
            emit AdminApproved(id);
        } else if (
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins
        ) {
            adminRequests[_losBankID][id].approved = true;
            adminRequests[_losBankID][id].rejected = false;
            adminRequests[_losBankID][id].allVoted = true;
            bankAdminReqs[_losBankID][requester].approved = true;
            bankAdminReqs[_losBankID][requester].rejected = false;
            bankAdminReqs[_losBankID][requester].allVoted = true;
            emit AdminApproved(id);
        } else if (
            adminRequests[_losBankID][id].voteCount == totalApprovedAdmins &&
            adminRequests[_losBankID][id].approvalCount ==
            adminRequests[_losBankID][id].rejectionCount
        ) {
            revert(
                "Equal Voting Scenario Asks for One more Admin Vote!"
            );
            // emit AdminApproved(id);
        }
    }

    function getAdmReqs(string memory _losBankId, uint256 bankID)
        external
        view
        onlyBankAdmin
        returns (AdminRequest memory)
    {
        return adminRequests[_losBankId][bankID];
    }

    function requestUserRole(
        string memory _losBankID,
        string memory roleType,
        string memory _name,
        string memory userDetails,
        string memory email
    ) external {
        require(
            isRBIVerifier[msg.sender] == false,
            "owner cannot request a role"
        );
        require(
            !regulators[msg.sender],
            "Regulators cannot request a user role"
        );
        require(
            !bankAdmins[msg.sender],
            "Bankadmins cannot request a user role"
        );
        require(
            keccak256(bytes(roleType)) == keccak256("user"),
            "Invalid role request type"
        );
        totalUserRoleRequests[_losBankID]++;
        require(bytes(roleType).length > 0, "Role type cannot be empty");

        // Check if user already has a pending request for the same role type or customer ID
        for (uint256 i = 0; i < totalUserRoleRequests[_losBankID]; i++) {
            require(keccak256(bytes(userRoleRequests[_losBankID][i].userDetails)) !=
                    keccak256(bytes(userDetails)), "User Request Already Present");
            require(keccak256(bytes(userRoleRequests[_losBankID][i].email)) !=
                    keccak256(bytes(email)), "User Request Already Present From This Email!");
            require(
                userRoleRequests[_losBankID][i].requester != msg.sender ||
                    keccak256(bytes(userRoleRequests[_losBankID][i].roleType)) !=
                    keccak256(bytes(roleType)) || 
                    userRoleRequests[_losBankID][i].approved == true &&
                    userRoleRequests[_losBankID][i].rejected == false ||
                    userRoleRequests[_losBankID][i].approved == false &&
                    userRoleRequests[_losBankID][i].rejected == true
                    ,
                "User already has a pending request for this role type"
            );
            require(
                userRoleRequests[_losBankID][i].userId != totalUserRoleRequests[_losBankID],
                "Customer ID already exists"
            );
        }
        RoleRequest storage newReq = userRoleRequests[_losBankID][
            totalUserRoleRequests[_losBankID]
        ];
        newReq.name = _name;
        newReq.email = email;
        newReq.userId = totalUserRoleRequests[_losBankID];
        newReq.requester = msg.sender;
        newReq.roleType = roleType;
        newReq.approved = false;
        newReq.rejected = false;
        newReq.approvalCount = 0;
        newReq.rejectionCount = 0;
        newReq.voteCount = 0;
        newReq.userDetails = userDetails;
        bankUserReqs[_losBankID][msg.sender] = newReq;
        RequestCounter++;
        emit RoleRequested(msg.sender, roleType, _name, totalUserRoleRequests[_losBankID]);
    }

    function approveUserRoleRequest(
        string memory _losBankID,
        uint256 _userId,
        uint256 totalApprovedAdmins,
        address requester,
        string memory adminEmail
    ) external onlyBankAdmin {
        require(hasAdminApprovedRejectedUserReq[msg.sender][_losBankID][_userId] == false, "Request Already Approved!");
        uint256 requiredApps = totalApprovedAdmins / 2;
        bool found = false;
        // Iterate through role requests to find the request with the provided customer ID
        for (uint256 i = 1; i <= totalUserRoleRequests[_losBankID]; i++) {
            if (userRoleRequests[_losBankID][i].userId == _userId) {
                require(
                    !userRoleRequests[_losBankID][i].approved,
                    "Request already approved"
                );
                require(
                    !userRoleRequests[_losBankID][i].rejected,
                    "Request already rejected"
                );
                // userRoleApprovals[msg.sender] = true;
                userRoleRequests[_losBankID][i].approvalCount++;
                userRoleRequests[_losBankID][i].voteCount++;
                bankUserReqs[_losBankID][requester].approvalCount++;
                bankUserReqs[_losBankID][requester].approvalCount++;
                if (userRoleRequests[_losBankID][i].approvalCount >= requiredApps+1) {
                userRoleRequests[_losBankID][i].approved = true;
                userRoleRequests[_losBankID][i].rejected = false;
                bankUserReqs[_losBankID][requester].approved = true;
                bankUserReqs[_losBankID][requester].rejected = false;
                hasAdminApprovedRejectedUserReq[msg.sender][_losBankID][_userId] = true;
                emit RoleApproved(i);
                }
                found = true;
                userRequestApprovers[_losBankID][i].push(adminEmail);
                break;
            }
        }
        require(found, "No role request found for the provided customer ID");
    }

    function rejectUserRoleRequest(
        string memory _losBankID,
        uint256 _userId,
        string memory _totalApprovedAdmins,
        address requester,
        string memory adminEmail
    ) external onlyBankAdmin {
        // Iterate through role requests to find the request with the provided customer ID
        require(hasAdminApprovedRejectedUserReq[msg.sender][_losBankID][_userId] == false, "Request Already Approved!");
        bool found = false;
        uint256 totalApprovedAdmins = stringToUint256(_totalApprovedAdmins);
        uint256 requiredApprs = totalApprovedAdmins/2;
        for (uint256 i = 1; i <= totalUserRoleRequests[_losBankID]; i++) {
            if (userRoleRequests[_losBankID][i].userId == _userId) {
                require(
                    !userRoleRequests[_losBankID][i].approved,
                    "Request already approved"
                );
                userRoleRequests[_losBankID][i].rejectionCount++;
                userRoleRequests[_losBankID][i].voteCount++;
                bankUserReqs[_losBankID][requester].rejectionCount++;
                bankUserReqs[_losBankID][requester].voteCount++;
                if (userRoleRequests[_losBankID][i].rejectionCount >= requiredApprs+1) {
                userRoleRequests[_losBankID][i].approved = false;
                userRoleRequests[_losBankID][i].rejected = true;
                bankUserReqs[_losBankID][requester].approved = false;
                bankUserReqs[_losBankID][requester].rejected = true;
                hasAdminApprovedRejectedUserReq[msg.sender][_losBankID][_userId] = true;
                }
                emit RoleRequestRejected(
                    i,
                    userRoleRequests[_losBankID][i].requester,
                    userRoleRequests[_losBankID][i].roleType
                );
                userRequestRejectors[_losBankID][i].push(adminEmail);
                found = true;
                break;
            }
        }
        // If no request is found for the provided customer ID, revert
        require(found, "No role request found for the provided customer ID");
    }

    function getUserRequests(string memory _losBankID)
        external
        view
        onlyBankAdmin
        returns (uint256)
    {
        return totalUserRoleRequests[_losBankID];
    }

    function isUserApproved(string memory _losBankID, uint256 _userID) public view returns(bool){
        return userRoleRequests[_losBankID][_userID].approved;
    }

    function isAdminApproved(string memory _losBankID, uint256 _userID) public view returns(bool){
        return adminRequests[_losBankID][_userID].approved;
    }

    function getAdmin(string memory _losBankID, address _walletAddress) public view returns(AdminRequest memory){
        return bankAdminReqs[_losBankID][_walletAddress];
    }

    function getUser(string memory _losBankID, address _walletAddress) public view returns(RoleRequest memory){
        return bankUserReqs[_losBankID][_walletAddress];
    }

    function getUserRoleRequestApprovers(string memory _losBankID, uint256 _userRequestID) public view returns(string[] memory){
        return userRequestApprovers[_losBankID][_userRequestID];
    }

    function getUserRoleRequestRejectors(string memory _losBankID, uint256 _userRequestID) public view returns(string[] memory){
        return userRequestRejectors[_losBankID][_userRequestID];
    }
}
