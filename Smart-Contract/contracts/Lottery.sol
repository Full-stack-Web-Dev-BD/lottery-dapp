// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    address public admin;
    uint public ticketPrice;
    uint public startTime;
    uint public endTime;
    string[] public raffleItems;
    string[] public raffleDescriptions;
    uint public purchasePeriod;
    uint public minimumParticipants;
    uint public maxTicketsPerUser;
    mapping(address => uint) public balance;
    mapping(address => uint) public ticketsPurchased;
    uint public totalRaised;
    uint public totalParticipants;
    bool public isTerminated;
    address public winner;

    event TicketsPurchased(address indexed user, uint tickets);
    event LotteryTerminated(uint totalRaised, address winner);

    constructor(
        uint _ticketPrice,
        uint _endTime,
        string[] memory _raffleItems,
        string[] memory _raffleDescriptions,
        uint _purchasePeriod,
        uint _minimumParticipants,
        uint _maxTicketsPerUser
    ) {
        admin = msg.sender;
        ticketPrice = _ticketPrice;
        startTime = block.timestamp;
        endTime = block.timestamp + (_endTime * 1 hours);
        raffleItems = _raffleItems;
        raffleDescriptions = _raffleDescriptions;
        purchasePeriod = _purchasePeriod;
        minimumParticipants = _minimumParticipants;
        maxTicketsPerUser = _maxTicketsPerUser;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier duringPurchasePeriod() {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Ticket purchase period has ended"
        );
        _;
    }

    modifier lotteryNotTerminated() {
        require(!isTerminated, "Lottery has been terminated");
        _;
    }

    function purchaseTickets(
        uint tickets
    ) external payable duringPurchasePeriod lotteryNotTerminated {
        require(tickets > 0, "Tickets must be greater than zero");
        require(msg.value == ticketPrice * tickets, "Invalid amount sent(+,-)");
        require(
            ticketsPurchased[msg.sender] + tickets <= maxTicketsPerUser,
            "Maximum tickets per user exceeded"
        );

        balance[msg.sender] += msg.value;
        ticketsPurchased[msg.sender] += tickets;
        totalRaised += msg.value;
        totalParticipants += 1;

        emit TicketsPurchased(msg.sender, tickets);
    }

    function withdrawFunds() external onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }

    function terminateLottery() external onlyAdmin {
        require(
            block.timestamp > endTime,
            "Lottery cannot be terminated before the end time"
        );
        require(
            totalParticipants >= minimumParticipants,
            "Lottery cannot be terminated as minimum participants not reached"
        );

        isTerminated = true;
        uint randomIndex = uint(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    totalParticipants
                )
            )
        ) % totalParticipants;
        uint count = 0;
        address winnerAddress;
        for (uint i = 0; i < raffleItems.length; i++) {
            for (uint j = 0; j < ticketsPurchased[msg.sender]; j++) {
                if (count == randomIndex) {
                    winnerAddress = msg.sender;
                    break;
                }
                count++;
            }
        }

        winner = winnerAddress;

        emit LotteryTerminated(totalRaised, winnerAddress);
    }

    function viewParticipants()
        external
        view
        onlyAdmin
        returns (address[] memory)
    {
        address[] memory participants = new address[](totalParticipants);
        uint index = 0;
        for (uint i = 0; i < raffleItems.length; i++) {
            for (uint j = 0; j < ticketsPurchased[msg.sender]; j++) {
                participants[index] = msg.sender;
                index++;
            }
        }
        return participants;
    }

    function viewUserTickets() external view returns (uint) {
        return ticketsPurchased[msg.sender];
    }

    function viewUserBalance() external view returns (uint) {
        return balance[msg.sender];
    }

    function viewTotalRaised() external view returns (uint) {
        return totalRaised;
    }

    function viewTotalParticipants() external view returns (uint) {
        return totalParticipants;
    }

    function viewRaffleItems() external view returns (string[] memory) {
        return raffleItems;
    }

    function viewRaffleDescriptions() external view returns (string[] memory) {
        return raffleDescriptions;
    }

    function viewPurchasePeriod() external view returns (uint) {
        return purchasePeriod;
    }

    function viewLotteryDetails()
        external
        view
        returns (uint, uint, uint, uint, uint, uint, uint, bool, address)
    {
        return (
            ticketPrice,
            startTime,
            endTime,
            purchasePeriod,
            minimumParticipants,
            maxTicketsPerUser,
            totalRaised,
            isTerminated,
            winner
        );
    }
}
