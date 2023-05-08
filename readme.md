
function selectWinner() external onlyAdmin lotteryNotTerminated {
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
                winnerAddress = ticketsPurchased[msg.sender];
                break;
            }
            count++;
        }
    }

    winner = winnerAddress;
}


100, 5, "Wone Car ","Wone car  by 1 USDT", 5, 10
tuple(tuple(uint256,uint256,uint256,string,string,uint256,uint256,uint256,uint256,bool,address),uint256,uint256,uint256[]): 100,1683541489,1683541729,My Raffle,Description of my raffle,10,5,400,1,false,0x0000000000000000000000000000000000000000,400,4,12641354597767665634590685636948203635584795963220368909696486568947050362764,61723151308899454596647775079105063969986853011852032808046019705563853745776,77053998938090853491954834629056094575675334476677182039203469675175158109481,102567555301903587427643895089918850630428820251534839492167187009667166422467
