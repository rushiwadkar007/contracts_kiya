// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.26;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MultiSigWallet.sol";
contract Betting is ReentrancyGuard {

    enum BetStatus {
        STARTED,
        ONGOING,
        CONCLUDED,
        WINNERSDECLARED
    }

    struct Punter {
        address uAddress;
        uint256 userID;
        uint256 numOfBets;
        uint256 totalBetsWon;
        uint256 totalBetsLost;
        bool isUser;
        bool isBlackListed;
    }

    struct Bitz {
        uint256 bitzId;
        uint256 bitzPrice;
        address challenger;
        bool isActive;
        bool isBetConcluded;
        uint256 betStartTime;
        uint256 betEndTime;
        string status;
    }

    mapping(address => mapping(uint256 => Bitz)) internal userWiseBets;
    mapping(address => mapping(uint256 => Bitz)) internal adminwiseBets;
    mapping(uint256 => BetStatus) public betStatus;
    uint256 public totalBets;

    event RequestFulfilled(
        bytes32 indexed bitzId,
        uint256 bit1ID,
        uint256 bitsID,
        uint256 eventId,
        address indexed playerAddress
    );

    event BetPublished(
        uint256 indexed _id,
        address indexed _challenger,
        uint256 indexed _price
    );

    event BetAccepted(
        uint256 indexed _id,
        address indexed _challenger,
        address indexed _accepter,
        uint256 _price
    );

    event BetClosed(
        uint256 indexed _id,
        uint256 indexed amount,
        address indexed _winner
    );

    address public admin1;
    address public admin2;
    address public admin3;
    MultiSigWallet public multSigwallet;
    
    constructor(
        address _admin1,
        address _admin2,
        address _admin3,
        MultiSigWallet _multisigwallet
    ) {
        multSigwallet = _multisigwallet;
        admin1 = _admin1;
        admin2 = _admin2;
        admin3 = _admin3;
    }

    error invalidAdmin(address adminAddress);

    modifier onlyAdmin(address admin) {
        if (msg.sender != admin) {
            revert invalidAdmin({adminAddress: msg.sender});
        }
        _;
    }

    function createBet(address admin, uint256 bitzPrice, uint256 betConludeTime) external onlyAdmin(admin) returns(bool){
        totalBets++;
        Bitz memory bit  = Bitz({
        bitzId : totalBets,
        bitzPrice : bitzPrice,
        challenger : admin,
        isActive : true,
        isBetConcluded : false,
        betStartTime : block.timestamp,
        betEndTime : betConludeTime,
        status : "STARTED"
        });
        adminwiseBets[msg.sender][totalBets] = bit;
        return true;
    }
}
