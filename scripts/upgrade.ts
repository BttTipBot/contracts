import { ethers, upgrades } from "hardhat";

const PROXY_TESTNET = '0xa5019Fe2B0AF5EC39d1Eb6A23B44CcA8e3d889F5'
const PROXY_MAINNET = '0x9F05ff7dcF4b8d73b32eEBd7DE1D9C8F19cEd24d'

const PROXY = PROXY_TESTNET

async function main() {
  const TipBot = await ethers.getContractFactory("TipBot");
  const tipbot = await upgrades.upgradeProxy(PROXY, TipBot);
  console.log("Box upgraded at:", tipbot.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  