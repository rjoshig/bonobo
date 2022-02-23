require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("@nomiclabs/hardhat-web3");


//PRINT ACCOUNT AND BALANCE
task("accounts", "Prints the list of accounts and balances", async (taskArgs, hre) => {
  const accounts = await web3.eth.getAccounts();

  for (const account of accounts) {
    const balance_wei = await web3.eth.getBalance(account);
    const balance_eth = web3.utils.fromWei(balance_wei, "ether")

    console.log(account, "---> ", balance_eth, "ETH");
  }
});


// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */module.exports = {

  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },

  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}` || "",
      accounts:
        process.env.PRIVATE_KEY_TESTNET !== undefined ? [process.env.PRIVATE_KEY_TESTNET] : [],
    },

    kovan: {
      url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY_TESTNET],
      chainId: 42,
      live: true,
      saveDeployments: true,
    },

    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY_TESTNET],
      chainId: 5,
      live: true,
      gasPrice: 10000000000,  // 10 GWei
      saveDeployments: true,
    },

    polygon: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY_POLYGON],
      saveDeployments: true,
    },

    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY_MAINNET],
      chainId: 1,
      live: true,
      saveDeployments: true,
    },


  },

  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },

  etherscan: {
    // npx hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
    apiKey: {
      rinkeby: process.env.ETHERSCAN_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY,
      kovan: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
    },
  },

};


module.exports = {
  solidity: {
    version: "0.7.1",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
};