import { ethers, upgrades } from "hardhat";

async function main () {
  const TipBot = await ethers.getContractFactory("TipBot");
  const tipbot = await upgrades.deployProxy(TipBot, {
  initializer: "initialize",
  });
  await tipbot.deployed();

  console.log("Box deployed to:", tipbot.address) ;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
