// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BitzToken.sol";
import "./MultiSigWallet.sol";

contract BitzBetting {

    address public admin;
    address[] public multisigWallet;
    BitzToken public token;
    IMultiSigWallet iMultiSigWallet;

    struct Event {
        uint256 id;
        string name;
        uint256 endTime;
        bool settled;
        uint8 winningRoomba;
        uint256 totalAmount;
        mapping(uint8 => uint256) bets;
        mapping(address => mapping(uint8 => uint256)) userBets;
        address[] punters;
        address[] winners;
        address[] losers;
    }

    mapping(uint256 => Event) public events;
    uint256 public eventCount;

    constructor(address[] memory _multisigWallet, BitzToken _token, IMultiSigWallet _iMultiSigWallet) {
        iMultiSigWallet = _iMultiSigWallet;
        admin = msg.sender;
        multisigWallet = _multisigWallet;
        token = _token;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyMultisig() {
        require(isMultisig(msg.sender), "Only multisig can call this function");
        _;
    }

    function isMultisig(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < multisigWallet.length; i++) {
            if (multisigWallet[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function createEvent(string memory _name, uint256 _endTime) public onlyAdmin {
        eventCount++;
        Event storage newEvent = events[eventCount];
        newEvent.id = eventCount;
        newEvent.name = _name;
        newEvent.endTime = _endTime;
        newEvent.settled = false;
    }

    function placeBet(uint256 _eventId, uint8 _roomba, uint256 betAmount) public {
        require(block.timestamp < events[_eventId].endTime, "Betting time has ended");
        require(betAmount > 0, "Bet amount must be greater than zero");
        events[_eventId].userBets[msg.sender][_roomba] += betAmount;
        events[_eventId].bets[_roomba] += betAmount;
        events[_eventId].totalAmount += betAmount;
        events[_eventId].punters.push(msg.sender);
    }

    function settleEvent(uint256 _eventId, uint8 _winningRoomba) public onlyMultisig {
        Event storage eventToSettle = events[_eventId];
        require(block.timestamp >= eventToSettle.endTime, "Event has not ended yet");
        require(!eventToSettle.settled, "Event already settled");

        eventToSettle.settled = true;
        eventToSettle.winningRoomba = _winningRoomba;

        // Determine winners and losers
        for (uint256 i = 0; i < eventToSettle.punters.length; i++) {
            address user = eventToSettle.punters[i];
            if (eventToSettle.userBets[user][_winningRoomba] > 0) {
                eventToSettle.winners.push(user);
            } else {
                eventToSettle.losers.push(user);
            }
        }

        // Mint and reward Bitz tokens to winners
        for (uint256 i = 0; i < eventToSettle.winners.length; i++) {
            address winner = eventToSettle.winners[i];
            uint256 userBet = eventToSettle.userBets[winner][_winningRoomba];
            uint256 reward = (userBet * eventToSettle.totalAmount) / eventToSettle.bets[_winningRoomba];
            token.approve(address(this), reward);
            token.transferOwnership(address(this));
            token.mint(winner, reward);
            iMultiSigWallet.incrementNonce();
        }
    }

    function claimReward(uint256 _eventId) public {
        Event storage eventToClaim = events[_eventId];
        require(eventToClaim.settled, "Event has not been settled yet");
        uint256 userBet = eventToClaim.userBets[msg.sender][eventToClaim.winningRoomba];
        require(userBet > 0, "No winnings to claim");

        uint256 reward = (userBet * eventToClaim.totalAmount) / eventToClaim.bets[eventToClaim.winningRoomba];
        eventToClaim.userBets[msg.sender][eventToClaim.winningRoomba] = 0;
        // payable(msg.sender).transfer(reward);
        token.transfer(msg.sender, reward);
    }

    function withdrawUnclaimedFunds(uint256 _eventId) public onlyAdmin {
        Event storage eventToWithdraw = events[_eventId];
        require(eventToWithdraw.settled, "Event must be settled before withdrawing");

        uint256 unclaimedAmount = eventToWithdraw.totalAmount - eventToWithdraw.bets[eventToWithdraw.winningRoomba];
        payable(admin).transfer(unclaimedAmount);
    }

    function getWinners(uint256 _eventId) public view returns (address[] memory) {
        return events[_eventId].winners;
    }

    function getLosers(uint256 _eventId) public view returns (address[] memory) {
        return events[_eventId].losers;
    }

    receive() external payable {}
}
