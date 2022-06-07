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

const { PRIVATE_KEY, API_KEY_ROPSTEN } = process.env;

module.exports = {
  defaultNetwork: "ropsten",
  networks: {
    hardhat: {},
    ropsten: {
      url: `https://ropsten.infura.io/v3/${API_KEY_ROPSTEN}`,
      accounts: [PRIVATE_KEY],
      chainId: 3,
    },
    fuji: {
      url: `https://api.avax-test.network/ext/bc/C/rpc`,
      accounts: [PRIVATE_KEY],
      chainId: 43113,
    },
    mumbai: {
      url: `https://matic-mumbai.chainstacklabs.com`,
      accounts: [PRIVATE_KEY],
      chainId: 80001,
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      ropsten: "QPNAACHSCIVH9WXF2ZSQ5UUX6HFMJ3ZRUR",
      rinkeby: "J7EZKJ8CMAIYEV8BVQZTF5Y5C9813X6U4C",
      polygonMumbai: "2S8PS4TS3163CEPNQWWT2PU1CAJIV9FFRM",
      avalancheFujiTestnet: "1AIWJPNBVABF512QFHNUDN9726TU2168FT",
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
