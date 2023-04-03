# mcross-smartcontract

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

# How to deploy smart contract
### Source Chain

1. Deploy MCrossBridgeNFTController, MCrossBrdigeNFT and MockCollection

```shell
  npm run deploy:goerli scripts scripts/deploy.js
```

2. Verify smart contract 

   **If your source chain is Goerli Testnet**

```shell
  npx hardhat verify --network goerli "YOUR CONTRACT ADDRESS MCrossBridgeNFTController"
  npx hardhat verify --network goerli "YOUR CONTRACT ADDRESS MCrossBrdigeNFT"  "CONTRACT ADDRESS AxelarExecutable" "CONTRACT ADDRESS AxelarGasReceiver" "CONTRACT ADDRESS MCrossBridgeNFTController"
```

### Destination Chain

1. Deploy MCrossBridgeNFTController, MCrossBrdigeNFT and MockCollection

```shell
  npm run deploy:fuji scripts scripts/deploy.js
```

2. Verify smart contract 

   **If your source chain is Avalance Testnet**

```shell
  npx hardhat verify --network fuji "YOUR CONTRACT ADDRESS MCrossBridgeNFTController"
  npx hardhat verify --network fuji "YOUR CONTRACT ADDRESS MCrossBrdigeNFT"  "CONTRACT ADDRESS AxelarExecutable" "CONTRACT ADDRESS AxelarGasReceiver" "CONTRACT ADDRESS MCrossBridgeNFTController"
```
### PS. In the file Deploy.js Assume if you want to deploy to Avalanche Testnet you must be enabled only the bridge Contract of Fuji. You must follow this example

```javaScript
  async function main() {
  // We get the contract to deploy

  const MCrossBridgeNFTController = await ethers.getContractFactory(
    "MCrossBridgeNFTController"
  );
  const controllerContract = await MCrossBridgeNFTController.deploy();
  await controllerContract.deployed();

  const MCrossBrdigeNFT = await await ethers.getContractFactory(
    "MCrossBrdigeNFT"
  );

  // Mumbai
  // const bridgeContract = await MCrossBrdigeNFT.deploy(
  //   "0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B",
  //   "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
  //   controllerContract.address
  // );

  //Fuji
  const bridgeContract = await MCrossBrdigeNFT.deploy(
    "0xC249632c2D40b9001FE907806902f63038B737Ab",
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
    controllerContract.address
  );

  //Ehereum
  // const bridgeContract = await MCrossBrdigeNFT.deploy(
  //   "0xBC6fcce7c5487d43830a219CA6E7B83238B41e71",
  //   "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
  //   controllerContract.address
  // );

  await bridgeContract.deployed();

  const MockCollection = await ethers.getContractFactory("MockCollection");
  const mockContract = await MockCollection.deploy();
  await mockContract.deployed();

  console.log(controllerContract.address);
  console.log(bridgeContract.address);
  console.log(mockContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

