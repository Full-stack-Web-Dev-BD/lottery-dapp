
const hre = require("hardhat");

async function main() { 
  const Lottery = await hre.ethers.getContractFactory("Lottery");
  const lottery = await Lottery.deploy('100',  '4', ['item1', 'item2', 'item3'], ['description1', 'description2', 'description3'], '604800', '4', '10')

  await lottery.deployed();

  console.log(
    `Lottery deployed to ${lottery.address}`
  );
}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
