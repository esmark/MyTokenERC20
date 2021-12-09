//require('dotenv').config();
import { config as dotenvConfig } from 'dotenv';
dotenvConfig();
import { NetworkUserConfig } from 'hardhat/types';
import 'hardhat-docgen'
//require("@nomiclabs/hardhat-waffle");
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
// import "@nomiclabs/hardhat-etherscan";
//require('solidity-coverage');
import "solidity-coverage";
import "./tasks";

//define chainIds for networks 
const chainIds = {
  mumbai: 80001,
  matic: 137
} 

// Ensure everything is in place
let mnemonic: string;
if (!process.env.MNEMONIC) {
  throw new Error('Please set your MNEMONIC in a .env file')
} else {
  mnemonic = process.env.MNEMONIC;
}
let infuraApiKey: string;
if (!process.env.INFURA_API_KEY) {
  throw new Error('Please set your INFURA_API_KEY in a .env file')
} else {
  infuraApiKey = process.env.INFURA_API_KEY;
}


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
/* task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
}); */


function createNetworkConfig(
  network: keyof typeof chainIds,
): NetworkUserConfig {
  const url: string = `https://polygon-${network}.infura.io/v3/${infuraApiKey}`;
  return {
    accounts: {
      count: 10,
      initialIndex: 0,
      mnemonic,
      path: "m/44'/60'/0'/0",
    },
    chainId: chainIds[network],
    gas: "auto",
    gasPrice: 30_000_000_000, // gwei
    url,
  };
}

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
//module.exports = {
export default {
  solidity: "0.8.4",
  defaultNetwork: 'hardhat',
  networks: {
    matic: createNetworkConfig('matic'),
    mumbai: createNetworkConfig('mumbai'),
    coverage: {
      url: 'http://localhost:8555'
    }
  },
  paths: {
    artifacts: './artifacts',
    cache: './cache',
    sources: './contracts',
    tests: './test'
  },
  mocha: {
    timeout: 20000
  },
  docgen: {
    path: './docs',
    runOnCompile: true
  }
};
