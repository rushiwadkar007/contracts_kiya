pragma solidity ^0.8.19;
import "./IMultiSigWallet.sol";

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
