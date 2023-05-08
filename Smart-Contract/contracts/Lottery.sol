// SPDX-License-Identifier: MIT
// 100, 5, ["Item A", "Item B", "Item C"], ["Description A", "Description B", "Description C"], 604800, 50, 10

pragma solidity ^0.8.0;

contract Lottery {
    address public admin;
    uint256 public ticketPrice;
    uint256 public startTime;
    uint256 public endTime;
    string[] public raffleItems;
    string[] public raffleDescriptions;
    uint256 public purchasePeriod;
    uint256 public minimumParticipants;
    uint256 public maxTicketsPerUser;
    mapping(address => uint256) public balance;
    mapping(address => uint256) public ticketsPurchased;
    uint256 public totalRaised;
    uint256 public totalParticipants;
    bool public isTerminated;
    address public winner;

    event TicketsPurchased(address indexed user, uint256 tickets);
    event LotteryTerminated(uint256 totalRaised, address winner);
    event FundsWithdrawn(address indexed user, uint256 amount);

    constructor(
        uint256 _ticketPrice,
        uint256 _endTime,
        string[] memory _raffleItems,
        string[] memory _raffleDescriptions,
        uint256 _purchasePeriod,
        uint256 _minimumParticipants,
        uint256 _maxTicketsPerUser
    ) {
        admin = msg.sender;
        ticketPrice = _ticketPrice;
        startTime = block.timestamp;
        endTime = block.timestamp + (_endTime * 1 minutes);
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

    function purchaseTickets(uint256 tickets)
        external
        payable
        duringPurchasePeriod
        lotteryNotTerminated
    {
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

    function withdrawFunds() external onlyAdmin duringPurchasePeriod {
        uint256 purchaseAmount = balance[msg.sender];
        require(purchaseAmount > 0, "No funds to withdraw");

        balance[msg.sender] = 0;
        ticketsPurchased[msg.sender] = 0;
        totalParticipants -= 1;
        totalRaised -= purchaseAmount;

        payable(msg.sender).transfer(purchaseAmount);

        emit FundsWithdrawn(msg.sender, purchaseAmount);
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
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.timestamp,
                    totalParticipants
                )
            )
        ) % totalParticipants;
        uint256 count = 0;
        address winnerAddress;
        for (uint256 i = 0; i < raffleItems.length; i++) {
            for (uint256 j = 0; j < ticketsPurchased[msg.sender]; j++) {
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
        uint256 index = 0;
        for (uint256 i = 0; i < raffleItems.length; i++) {
            for (uint256 j = 0; j < ticketsPurchased[msg.sender]; j++) {
                participants[index] = msg.sender;
                index++;
            }
        }
        return participants;
    }

    function viewUserTickets() external view returns (uint256) {
        return ticketsPurchased[msg.sender];
    }

    function viewUserBalance() external view returns (uint256) {
        return balance[msg.sender];
    }

    function viewTotalRaised() external view returns (uint256) {
        return totalRaised;
    }

    function viewTotalParticipants() external view returns (uint256) {
        return totalParticipants;
    }

    function viewRaffleItems() external view returns (string[] memory) {
        return raffleItems;
    }

    function viewRaffleDescriptions() external view returns (string[] memory) {
        return raffleDescriptions;
    }

    function viewPurchasePeriod() external view returns (uint256) {
        return purchasePeriod;
    }

    function viewLotteryDetails()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            address
        )
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
