// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() { 
  const Lottery = await hre.ethers.getContractFactory("Lottery");
  const lottery = await Lottery.deploy('100',  '4', ['item1', 'item2', 'item3'], ['description1', 'description2', 'description3'], '604800', '4', '10')

  await lottery.deployed();

  console.log(
    `Lottery deployed to ${lottery.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
