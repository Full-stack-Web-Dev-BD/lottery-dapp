
// Imports
const { ethers } = require('hardhat');
const { solidity, 
    MockProvider,
    deployContract } = require('ethereum-waffle');
const { expect } = require('chai');

// Tested Contract
import Lottery from '../contracts/Lottery.sol';

// Test Helper Functions
const getSigner = async () => {
    return (await ethers.getSigners())[0];
};

// Test Setup
let signer;
let lottery;
let admin;

beforeEach(async () => {
    signer = await getSigner();
    admin = signer._address;
    lottery = await deployContract(signer, Lottery, [
        1,
        0,
        2000000000,
        ['item1', 'item2'],
        ['Item 1 Description', 'Item 2 Description'],
        2592000,
        3,
        10
    ]);
});

// Tests
describe('Lottery', () => {
    it('Should have set the admin address', async () => {
        expect(await lottery.admin()).to.equal(admin);
    });

    it('Should have set the ticket price', async () => {
        expect(await lottery.ticketPrice()).to.equal(1);
    });

    it('Should have set the start time', async () => {
        expect(await lottery.startTime()).to.equal(0);
    });

    it('Should have set the end time', async () => {
        expect(await lottery.endTime()).to.equal(2000000000);
    });

    it('Should have set the raffle items', async () => {
        const expectedRaffleItems = ['item1', 'item2'];
        const raffleItems = await lottery.raffleItems();
        expect(raffleItems).to.deep.equal(expectedRaffleItems);
    });

    it('Should have set the raffle descriptions', async () => {
        const expectedRaffleDescriptions = ['Item 1 Description', 'Item 2 Description'];
        const raffleDescriptions = await lottery.raffleDescriptions();
        expect(raffleDescriptions).to.deep.equal(expectedRaffleDescriptions);
    });

    it('Should have set the purchase period', async () => {
        expect(await lottery.purchasePeriod()).to.equal(2592000);
    });

    it('Should have set the minimum participants', async () => {
        expect(await lottery.minimumParticipants()).to.equal(3);
    });

    it('Should have set the max tickets per user', async () => {
        expect(await lottery.maxTicketsPerUser()).to.equal(10);
    });

    it('Should allow a user to purchase tickets', async () => {
        const secondSigner = await getSigner();
        const secondSignerAddress = secondSigner._address;

        const expectedBalance = 1;
        const expectedTicketsPurchased = 1;

        await lottery.purchaseTickets(1, { value: 1, from: secondSignerAddress });

        expect(await lottery.balance(secondSignerAddress)).to.equal(expectedBalance);
        expect(await lottery.ticketsPurchased(secondSignerAddress)).to.equal(expectedTicketsPurchased);
    });

    it('Should allow the admin to withdraw funds', async () => {
        const expectedTotalRaised = 0;
        await lottery.withdrawFunds();
        expect(await lottery.totalRaised()).to.equal(expectedTotalRaised);
    });

    it('Should allow the admin to terminate the lottery', async () => {
        const expectedTotalRaised = 1;
        const expectedTotalParticipants = 1;
        const expectedIsTerminated = true;

        await lottery.purchaseTickets(1, { value: 1, from: admin });
        await lottery.terminateLottery();

        expect(await lottery.totalRaised()).to.equal(expectedTotalRaised);
        expect(await lottery.totalParticipants()).to.equal(expectedTotalParticipants);
        expect(await lottery.isTerminated()).to.equal(expectedIsTerminated);
    });

    it('Should allow a user to view their tickets', async () => {
        const expectedTicketsPurchased = 1;

        await lottery.purchaseTickets(1, { value: 1, from: admin });
        expect(await lottery.viewUserTickets()).to.equal(expectedTicketsPurchased);
    });

    it('Should allow a user to view their balance', async () => {
        const expectedBalance = 1;

        await lottery.purchaseTickets(1, { value: 1, from: admin });
        expect(await lottery.viewUserBalance()).to.equal(expectedBalance);
    });

    it('Should allow a user to view the total raised', async () => {
        const expectedTotalRaised = 1;

        await lottery.purchaseTickets(1, { value: 1, from: admin });
        expect(await lottery.viewTotalRaised()).to.equal(expectedTotalRaised);
    });

    it('Should allow a user to view the total participants', async () => {
        const expectedTotalParticipants = 1;

        await lottery.purchaseTickets(1, { value: 1, from: admin });
        expect(await lottery.viewTotalParticipants()).to.equal(expectedTotalParticipants);
    });

    it('Should allow a user to view the raffle items', async () => {
        const expectedRaffleItems = ['item1', 'item2'];

        expect(await lottery.viewRaffleItems()).to.deep.equal(expectedRaffleItems);
    });

    it('Should allow a user to view the raffle descriptions', async () => {
        const expectedRaffleDescriptions = ['Item 1 Description', 'Item 2 Description'];

        expect(await lottery.viewRaffleDescriptions()).to.deep.equal(expectedRaffleDescriptions);
    });

    it('Should allow a user to view the purchase period', async () => {
        const expectedPurchasePeriod = 2592000;

        expect(await lottery.viewPurchasePeriod()).to.equal(expectedPurchasePeriod);
    });

    it('Should allow a user to view the lottery details', async () => {
        const expectedLotteryDetails = [
            1,
            0,
            2000000000,
            2592000,
            3,
            10,
            0,
            false,
            '0x0000000000000000000000000000000000000000'
        ];

        expect(await lottery.viewLotteryDetails()).to.deep.equal(expectedLotteryDetails);
    });
});