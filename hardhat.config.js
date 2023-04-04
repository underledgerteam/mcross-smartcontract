require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const {
  PRIVATE_KEY,
  GOERLI_URL,
  MUMBAI_URL,
  FUJI_URL,
  GOERLI_SCAN_API_KEY,
  MUMBAI_SCAN_API_KEY,
  FUJI_SCAN_API_KEY,
} = process.env;

module.exports = {
  defaultNetwork: "goerli",
  networks: {
    hardhat: {},
    goerli: {
      url: GOERLI_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
    },
    fuji: {
      url: FUJI_URL,
      accounts: [PRIVATE_KEY],
      chainId: 43113,
    },
    mumbai: {
      url: MUMBAI_URL,
      accounts: [PRIVATE_KEY],
      chainId: 80001,
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      goerli: GOERLI_SCAN_API_KEY,
      polygonMumbai: MUMBAI_SCAN_API_KEY,
      avalancheFujiTestnet: FUJI_SCAN_API_KEY,
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    paths: {
      sources: "./contracts",
      tests: "./test",
      cache: "./cache",
      artifacts: "./artifacts",
    },
    mocha: {
      timeout: 400000,
    },
    gasReporter: {
      enabled: false,
    },
  },
};
