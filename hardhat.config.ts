import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";

require("dotenv").config();

const TESTNET_PRIVATE_KEY = process.env.TESTNET_PRIVATE_KEY;
const MAINNET_PRIVATE_KEY = process.env.MAINNET_PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    bttcTestnet: {
      url: "https://pre-rpc.bt.io/",
      accounts: [`${TESTNET_PRIVATE_KEY}`]
    },
    bttc: {
      url: "https://rpc.bt.io/",
      accounts: [`${MAINNET_PRIVATE_KEY}`]
    },
  },
  etherscan: {
    apiKey: {
      bttc: process.env.BTTC_API_KEY ? process.env.BTTC_API_KEY.toString() : '',
      bttcTestnet: process.env.BTTC_TESTNET_API_KEY ? process.env.BTTC_TESTNET_API_KEY.toString() : ''
    },
    customChains: [
      {
        network: "bttcTestnet",
        chainId: 1029,
        urls: {
          apiURL: "https://api-testnet.bttcscan.com/api",
          browserURL: "https://testnet.bttcscan.com/"
        }
      },
      {
        network: "bttc",
        chainId: 199,
        urls: {
          apiURL: "https://api.bttcscan.com/api",
          browserURL: "https://bttcscan.com/"
        }
      }
    ],
  }
};

export default config;
