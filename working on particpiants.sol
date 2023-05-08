// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

// 100,4, "My Raffle", "Description of my raffle", 10, 5
contract Lottery {
    address public admin;
    uint256 public raffleCount = 0;
    mapping(uint256 => Raffle) public getRaffleByID;
    mapping(address => uint256[]) public getParticipantRaffles;

    // Raffle Data
    mapping(uint256 => mapping(address => uint256)) balance;
    mapping(uint256 => mapping(address => uint256)) ticketsPurchased;
    mapping(uint256 => mapping(address => uint256[])) tickets;
    mapping(uint256 => address[]) public raffleParticipants;

    struct Raffle {
        uint256 ticketPrice;
        uint256 startTime;
        uint256 endTime;
        string raffleTitle;
        string raffleDescriptions;
        uint256 minimumParticipants;
        uint256 maxTicketsPerUser;
        uint256 totalRaised;
        bool isTerminated;
        address winner;
    }

    event TicketsPurchased(address indexed user, uint256 tickets);
    event LotteryTerminated(uint256 totalRaised, address winner);

    constructor() {
        admin = msg.sender;
    }

    modifier raffleExists(uint256 raffleID) {
        require(
            getRaffleByID[raffleID].ticketPrice > 0,
            "Raffle does not exist"
        );
        _;
    }

    function addRaffleParticipant(uint256 _number, address _address) private {
        // check if address already exists
        bool exists = false;
        for (uint256 i = 0; i < raffleParticipants[_number].length; i++) {
            if (raffleParticipants[_number][i] == _address) {
                exists = true;
                break;
            }
        }
        // add address if it doesn't exist
        if (!exists) {
            raffleParticipants[_number].push(_address);
        }
    }

    function getRaffleParticipants(uint256 _raffleID)
        public
        view
        returns (address[] memory)
    {
        return raffleParticipants[_raffleID];
    }

    function createRaffle(
        uint256 _ticketPrice,
        uint256 _endTime,
        string memory _raffleTitle,
        string memory _raffleDescriptions,
        uint256 _minimumParticipants,
        uint256 _maxTicketsPerUser
    ) public {
        require(msg.sender == admin, "Only the admin can create raffles");
        require(_ticketPrice > 0, "Ticket price must be greater than 0");
        require(
            _endTime > 3,
            "Please allow at least 3 minute to perticipate on raffle"
        );
        require(
            _minimumParticipants > 0,
            "Minimum participants must be greater than 0"
        );
        require(
            _maxTicketsPerUser > 0,
            "Max tickets per user must be greater than 0"
        );
        uint256 _totalRaised = 0;
        uint256 _startTime = block.timestamp;
        bool _isTerminated = false;
        address _winner = address(0);
        Raffle memory newRaffle = Raffle(
            _ticketPrice,
            _startTime,
            _endTime = block.timestamp + (_endTime * 1 minutes),
            _raffleTitle,
            _raffleDescriptions,
            _minimumParticipants,
            _maxTicketsPerUser,
            _totalRaised,
            _isTerminated,
            _winner
        );
        getRaffleByID[raffleCount] = newRaffle;
        raffleCount++;
    }

    function timeRemaining(uint256 _raffleID)
        public
        view
        raffleExists(_raffleID)
        returns (uint256)
    {
        uint256 currentTime = block.timestamp;
        uint256 endTime = getRaffleByID[_raffleID].endTime;

        if (currentTime > endTime) {
            return 0;
        } else {
            return (endTime - currentTime);
        }
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier duringPurchasePeriod(uint256 _raffleID) {
        uint256 startTime = getRaffleByID[_raffleID].startTime;
        uint256 endTime = getRaffleByID[_raffleID].endTime;

        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Ticket purchase period has ended"
        );
        _;
    }

    modifier lotteryNotTerminated(uint256 _raffleID) {
        bool isTerminated = getRaffleByID[_raffleID].isTerminated;
        require(!isTerminated, "Lottery has been terminated");
        _;
    }

    function purchaseTickets(uint256 _raffleID, uint256 ticketAmount)
        external
        payable
        raffleExists(_raffleID)
        duringPurchasePeriod(_raffleID)
        lotteryNotTerminated(_raffleID)
    {
        uint256 ticketPrice = getRaffleByID[_raffleID].ticketPrice;
        uint256 maxTicketsPerUser = getRaffleByID[_raffleID].maxTicketsPerUser;

        require(ticketAmount > 0, "Tickets must be greater than zero");
        require(
            msg.value == ticketPrice * ticketAmount,
            "Invalid amount sent(+,-)"
        );
        require(
            ticketsPurchased[_raffleID][msg.sender] + ticketAmount <=
                maxTicketsPerUser,
            "Maximum ticketAmount per user exceeded"
        );

        balance[_raffleID][msg.sender] += msg.value;
        ticketsPurchased[_raffleID][msg.sender] += ticketAmount;
        getRaffleByID[_raffleID].totalRaised += msg.value;
        addRaffleParticipant(_raffleID, msg.sender);

        for (uint256 i = 0; i < ticketAmount; i++) {
            tickets[_raffleID][msg.sender].push(
                uint256(keccak256(abi.encodePacked(msg.sender, i)))
            );
        }

        emit TicketsPurchased(msg.sender, ticketAmount);
    }

    function viewMyTickets(uint256 _raffleID)
        public
        view
        raffleExists(_raffleID)
        returns (uint256[] memory)
    {
        return tickets[_raffleID][msg.sender];
    }

    function viewUserParticipantOnRaffle(uint256 _raffleID)
        external
        view
        raffleExists(_raffleID)
        returns (uint256)
    {
        return balance[_raffleID][msg.sender];
    }

    struct LotteryDetails {
        Raffle raffle;
        uint256 balance;
        uint256 ticketsPurchased;
        uint256[] tickets;
    }

    function viewLotteryDetails(uint256 _raffleID)
        public
        view
        raffleExists(_raffleID)
        returns (LotteryDetails memory)
    {
        LotteryDetails memory currentLottery;
        currentLottery.raffle = getRaffleByID[_raffleID];
        currentLottery.balance = balance[_raffleID][msg.sender];
        currentLottery.ticketsPurchased = ticketsPurchased[_raffleID][
            msg.sender
        ];
        currentLottery.tickets = tickets[_raffleID][msg.sender];
        return currentLottery;
    }
}