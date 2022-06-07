async function main() {
  // We get the contract to deploy
  const MCrossMintController = await ethers.getContractFactory(
    "MCrossMintController"
  );
  const mcrossContract = await MCrossMintController.deploy(
    "0x3613C187b3eF813619A25322595bA5E297E4C08a"
  );
  await mcrossContract.deployed();
  const MCrossBridgeToken = await ethers.getContractFactory(
    "MCrossBridgeToken"
  );
  const mcrossBridgeTokenContract = await MCrossBridgeToken.deploy(
    "0x3613C187b3eF813619A25322595bA5E297E4C08a",
    "0xC249632c2D40b9001FE907806902f63038B737Ab",
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
    mcrossContract.address
  );
  await mcrossBridgeTokenContract.deployed();
  console.log("controller contract =====>", mcrossContract.address);
  console.log("bridge contract =====>", mcrossBridgeTokenContract.address);
}

// npx hardhat verify --network fuji 0x847f14bAbA858d81DC56449EF8C07DB8F8A1dc20 "0x3613C187b3eF813619A25322595bA5E297E4C08a"
// npx hardhat verify --network fuji 0x65794aEDe1b0C6085f73e050AE48836B05E0c982 "0x3613C187b3eF813619A25322595bA5E297E4C08a" "0xC249632c2D40b9001FE907806902f63038B737Ab" "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6" "0x847f14bAbA858d81DC56449EF8C07DB8F8A1dc20"

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
