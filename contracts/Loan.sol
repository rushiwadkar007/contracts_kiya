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

interface IDepositTokenization {
    struct CertificateRequest {
        string bankID;
        string certificateID;
        uint256 certBlockchainTokenID;
        address certificateOwner;
        uint256 userID;
        string certDetails;
        uint256 certCreationTimestamp;
        uint256 totalApprovals;
        uint256 totalRejections;
        bool isApproved;
        bool isRejected;
        bool allVoted;
    }

    function reqTokenization(
        string memory _losBankID,
        string memory _certID,
        string memory _certDetails,
        uint256 _userID,
        uint256 _depositTenure,
        uint256 _depositAmount,
        IMultiSigWallet _iMultSigWallet
    ) external returns (bool certRequest);

    function approveTokenization(
        string memory _losBankID,
        string memory url,
        IMultiSigWallet _iMultSigWallet,
        uint256 trxNo,
        string memory adminEmail,
        uint256 _adminID
    ) external returns (bool certRequest);

    function rejectTokenization(
        string memory _losBankID,
        string memory url,
        IMultiSigWallet _iMultSigWallet,
        uint256 trxNo,
        string memory adminEmail,
        uint256 _adminID
    ) external returns (bool certRequest);

    function getTokenizationRequests(
        string memory _losBankID,
        uint256 requestID,
        uint256 _userID
    ) external view returns (CertificateRequest memory);

    function getTokenApprovers(string memory losBankID, uint256 tokenRequestID)
        external
        view
        returns (string[] memory);

    function getTokenRejectors(string memory losBankID, uint256 tokenRequestID)
        external
        view
        returns (string[] memory);

    function getDepositAmount(string memory _losBankID)
        external
        view
        returns (uint256);

    function getDepositTenure(string memory _losBankID)
        external
        view
        returns (uint256);
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
    ) external returns (bool);

    function getTransactionHash(
        uint256 _nonce,
        address to,
        uint256 value
    ) external view returns (bytes32);

    function recover(bytes32 _hash, bytes memory _signature)
        external
        pure
        returns (address);

    function verifyUserSign(string memory _passkey, bytes memory signature)
        external
        pure
        returns (address userWalletAddress);

    function totalTransactionValidations(uint256 trxNo)
        external
        view
        returns (uint256);

    function incrementNonce() external returns (uint256);
}

// File: contracts/IMultiSigFactory.sol

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

pragma solidity ^0.8.0;

contract LoanAgainstDeposits {
    address public owner;
    ITokenizationRoleManager public iTokenizationRoleManager;
    IMultiSigWallet public iMultiSigWallet;
    IMultiSigFactory public iMultiSigFactory;
    IDepositTokenization public iDepositTokenization;
    enum ProposalState {
        WAITING,
        ACCEPTED,
        REPAID
    }

    struct Proposal {
        address lender;
        uint256 loanId;
        ProposalState state;
        uint256 rate;
        uint256 amount;
    }

    enum LoanState {
        ACCEPTING,
        LOCKED,
        SUCCESSFUL,
        FAILED
    }

    struct Loan {
        address borrower;
        address lender;
        uint256 depositID;
        LoanState state;
        uint256 dueDate;
        uint256 amount;
        uint256 proposalCount;
        uint256 collected;
        uint256 startDate;
        bytes32 mortgage;
    }

    mapping(uint256 => Loan) public loanList;
    mapping(uint256 => Proposal) public lendList;
    Proposal[] public proposalList;

    mapping(address => uint256) public loanMap;
    mapping(address => uint256) public lendMap;
    mapping(uint256 => uint256) proposal;

    constructor(
        ITokenizationRoleManager _iTokenizationRoleManager,
        IMultiSigWallet _iMultiSigWallet,
        IDepositTokenization _iDepositTokenization
    ) {
        owner = msg.sender;
        iTokenizationRoleManager = _iTokenizationRoleManager;
        iMultiSigWallet = _iMultiSigWallet;
        iDepositTokenization = _iDepositTokenization;
    }

    function hasActiveLoan(address borrower, uint256 loanID)
        public
        view
        returns (bool, Loan memory)
    {
        if (loanID != 0) {
            Loan storage obj = loanList[loanMap[borrower]];
            if (loanList[loanID].state == LoanState.ACCEPTING)
                return (true, obj);
            if (loanList[loanID].state == LoanState.LOCKED) return (true, obj);
            return (false, obj);
        }
    }

    function requestLoan(
        uint256 _userID,
        uint256 amount,
        string memory losBankID,
        uint256 depositID,
        uint256 dueDate,
        bytes32 mortgage,
        uint256 rate,
        address lender
    ) public {
        ITokenizationRoleManager.RoleRequest memory roleReq;
        IDepositTokenization.CertificateRequest memory cert;
        cert = iDepositTokenization.getTokenizationRequests(losBankID, depositID, _userID);
        require(cert.isApproved == true, "Loan Cannot be Granted Against This Loan!");
        roleReq = iTokenizationRoleManager.getUser(losBankID, msg.sender);
        require(roleReq.approved == true, "Unauthorised User!");
        require(owner != msg.sender, "Invalid Customer");
        loanMap[msg.sender]++;
        loanList[loanMap[msg.sender]].proposalCount++;
        (bool hasLoan, Loan memory l) = hasActiveLoan(
            msg.sender,
            loanMap[msg.sender]
        );
        if (hasLoan == false) return;
        uint256 currentDate = block.timestamp;
        Loan memory loan = Loan({
            borrower: msg.sender,
            lender: lender,
            depositID: depositID,
            state: LoanState.ACCEPTING,
            dueDate: dueDate,
            amount: amount,
            proposalCount: loanList[loanMap[msg.sender]].proposalCount,
            collected: 0,
            startDate: currentDate,
            mortgage: mortgage
        });
        loanList[loanMap[msg.sender]] = loan;
        // loanMap[msg.sender].push(loanList.length-1);
        newProposal(loanMap[msg.sender], rate, amount, lender);
    }

    function newProposal(
        uint256 loanId,
        uint256 rate,
        uint256 amount,
        address lender
    ) internal {
        if (
            loanList[loanId].borrower == address(0) ||
            loanList[loanId].state != LoanState.ACCEPTING
        ) return;
        lendMap[lender]++;
        Proposal memory p = Proposal({
            lender: lender,
            loanId: loanId,
            state: ProposalState.WAITING,
            rate: rate,
            amount: amount
        });
        proposalList.push(p);
        lendList[lendMap[lender]] = p;
        proposal[loanList[loanId].proposalCount - 1] = proposalList.length - 1;
    }

    //      function getActiveLoanId(address borrower) public view returns(uint) {
    //         uint numLoans = loanMap[borrower].length;
    //         if(numLoans == 0) return (2**64 - 1);
    //         uint lastLoanId = loanMap[borrower][numLoans-1];
    //         if(loanList[lastLoanId].state != LoanState.ACCEPTING) return (2**64 - 1);
    //         return lastLoanId;
    //     }

    //      function revokeMyProposal(uint id) public {
    //         uint proposeId = lendMap[msg.sender][id];
    //         if(proposalList[proposeId].state != ProposalState.WAITING) return;
    //         uint loanId = proposalList[proposeId].loanId;
    //         if(loanList[loanId].state == LoanState.ACCEPTING) {
    //             // Lender wishes to revoke his ETH when proposal is still WAITING
    //             proposalList[proposeId].state = ProposalState.REPAID;
    //             // msg.sender.transfer(proposalList[proposeId].amount);
    //         }
    //         else if(loanList[loanId].state == LoanState.LOCKED) {
    //             // The loan is locked/accepting and the due date passed : transfer the mortgage
    //             if(loanList[loanId].dueDate < now) return;
    //             loanList[loanId].state = LoanState.FAILED;
    //             for(uint i = 0; i < loanList[loanId].proposalCount; i++) {
    //                 uint numI = loanList[loanId].proposal[i];
    //                 if(proposalList[numI].state == ProposalState.ACCEPTED) {
    //                     // transfer mortgage
    //                 }
    //             }
    //         }
    //     }

    //      function lockLoan(uint loanId) public {
    //         //contract will send money to msg.sender
    //         //states of proposals would be finalized, not accepted proposals would be reimbursed
    //         if(loanList[loanId].state == LoanState.ACCEPTING)
    //         {
    //           loanList[loanId].state = LoanState.LOCKED;
    //           for(uint i = 0; i < loanList[loanId].proposalCount; i++)
    //           {
    //             uint numI = loanList[loanId].proposal[i];
    //             if(proposalList[numI].state == ProposalState.ACCEPTED)
    //             {
    //             //   msg.sender.transfer(proposalList[numI].amount); //Send to borrower
    //             }
    //             else
    //             {
    //               proposalList[numI].state = ProposalState.REPAID;
    //             //   proposalList[numI].lender.transfer(proposalList[numI].amount); //Send back to lender
    //             }
    //           }
    //         }
    //         else
    //           return;
    //     }

    //     //Amount to be Repaid
    //      function getRepayValue(uint loanId) public view returns(uint) {
    //         if(loanList[loanId].state == LoanState.LOCKED)
    //         {
    //           uint time = loanList[loanId].startDate;
    //           uint finalamount = 0;
    //           for(uint i = 0; i < loanList[loanId].proposalCount; i++)
    //           {
    //             uint numI = loanList[loanId].proposal[i];
    //             if(proposalList[numI].state == ProposalState.ACCEPTED)
    //             {
    //               uint original = proposalList[numI].amount;
    //               uint rate = proposalList[numI].rate;
    //               uint now = block.timestamp;
    //               uint interest = (original*rate*(now - time))/(365*24*60*60*100);
    //               finalamount += interest;
    //               finalamount += original;
    //             }
    //           }
    //           return finalamount;
    //         }
    //         else
    //           return (2**64 -1);
    //     }

    //      function repayLoan(uint loanId) public {
    //       uint now = block.timestamp;
    //       uint toBePaid = getRepayValue(loanId);
    //       uint time = loanList[loanId].startDate;
    //       uint paid = 0;
    //       if(paid >= toBePaid)
    //       {
    //         uint remain = paid - toBePaid;
    //         loanList[loanId].state = LoanState.SUCCESSFUL;
    //         for(uint i = 0; i < loanList[loanId].proposalCount; i++)
    //         {
    //           uint numI = loanList[loanId].proposal[i];
    //           if(proposalList[numI].state == ProposalState.ACCEPTED)
    //           {
    //             uint original = proposalList[numI].amount;
    //             uint rate = proposalList[numI].rate;
    //             uint interest = (original*rate*(now - time))/(365*24*60*60*100);
    //             uint finalamount = interest + original;
    //             // proposalList[numI].lender.transfer(finalamount);
    //             proposalList[numI].state = ProposalState.REPAID;
    //           }
    //         }
    //         // msg.sender.transfer(remain);
    //       }
    //       else
    //       {
    //         // msg.sender.transfer(paid);
    //       }
    //     }

    //      function acceptProposal(uint proposeId) public
    //     {
    //         uint loanId = getActiveLoanId(msg.sender);
    //         if(loanId == (2**64 - 1)) return;
    //         Proposal storage pObj = proposalList[proposeId];
    //         if(pObj.state != ProposalState.WAITING) return;

    //         Loan storage lObj = loanList[loanId];
    //         if(lObj.state != LoanState.ACCEPTING) return;

    //         if(lObj.collected + pObj.amount <= lObj.amount)
    //         {
    //           loanList[loanId].collected += pObj.amount;
    //           proposalList[proposeId].state = ProposalState.ACCEPTED;
    //         }
    //     }

    //      function totalProposalsBy(address lender) public view returns(uint) {
    //         return lendMap[lender].length;
    //     }

    //      function getProposalAtPosFor(address lender, uint pos) public view returns(address, uint, ProposalState, uint, uint, uint, uint, bytes32) {
    //         Proposal storage prop = proposalList[lendMap[lender][pos]];
    //         return (prop.lender, prop.loanId, prop.state, prop.rate, prop.amount, loanList[prop.loanId].amount, loanList[prop.loanId].dueDate, loanList[prop.loanId].mortgage);
    //     }

    // // BORROWER ACTIONS AVAILABLE

    //      function totalLoansBy(address borrower) public view returns(uint) {
    //         return loanMap[borrower].length;
    //     }

    //      function getLoanDetailsByAddressPosition(address borrower, uint pos) public view returns(LoanState, uint, uint, uint, uint,bytes32) {
    //         Loan storage obj = loanList[loanMap[borrower][pos]];
    //         return (obj.state, obj.dueDate, obj.amount, obj.collected, loanMap[borrower][pos], obj.mortgage);
    //     }

    //      function getLastLoanState(address borrower) public view returns(LoanState) {
    //         uint loanLength = loanMap[borrower].length;
    //         if(loanLength == 0)
    //             return LoanState.SUCCESSFUL;
    //         return loanList[loanMap[borrower][loanLength -1]].state;
    //     }

    //      function getLastLoanDetails(address borrower) public view returns(LoanState, uint, uint, uint, uint) {
    //         uint loanLength = loanMap[borrower].length;
    //         Loan storage obj = loanList[loanMap[borrower][loanLength -1]];
    //         return (obj.state, obj.dueDate, obj.amount, obj.proposalCount, obj.collected);
    //     }

    //      function getProposalDetailsByLoanIdPosition(uint loanId, uint numI) public view returns(ProposalState, uint, uint, uint, address) {
    //         Proposal storage obj = proposalList[loanList[loanId].proposal[numI]];
    //         return (obj.state, obj.rate, obj.amount, loanList[loanId].proposal[numI],obj.lender);
    //     }

    //      function numTotalLoans() public view returns(uint) {
    //         return loanList.length;
    //     }
}
