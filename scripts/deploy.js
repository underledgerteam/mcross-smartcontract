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

// mumbai
// npx hardhat verify --network mumbai 0xF8D99A22b3a6bDDd45a1ec65f413d8c59dE3B880
// npx hardhat verify --network mumbai 0x8b9F3441BC3aE4F0600c0428943dc9638D33393e  "0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B" "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6" "0x7bbF0937583BA80c963b06f1b7F945A43F3e364A"

// fuji
// npx hardhat verify --network fuji 0x8cFA110e91c99bb74C59b89c351DBd0944D15590
// npx hardhat verify --network fuji 0xFa027572eB12dc51EB5731F0d6c29D2f6135b341  "0xC249632c2D40b9001FE907806902f63038B737Ab" "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6" "0xae6Bee16840278244060A618465C4A4F08EDEd04"

//ethereum
// npx hardhat verify --network ropsten 0xACC880D9318349C5e6484e83C8AEa6a3a1591878
// npx hardhat verify --network ropsten 0xb1B10bBa4F68cFb4c08d51b13F1cA5baDcf8Aecd  "0xBC6fcce7c5487d43830a219CA6E7B83238B41e71" "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6" "0x7Fb50EFB1Fb534BEe353EF60715E54Ba31694065"
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
