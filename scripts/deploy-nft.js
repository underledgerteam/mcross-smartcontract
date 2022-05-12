async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(deployer.address);

  // We get the contract to deploy
  const MCrossCollection = await ethers.getContractFactory("MCrossCollection");
  const contract = await MCrossCollection.deploy(
    "MCross NFT",
    "MCROSS",
    "ipfs://QmYuooZLrfDFY1P5CSfpr5SCj2UiLejdLpJUtfxsS87L9T/",
    "0xbc6fcce7c5487d43830a219ca6e7b83238b41e71"
  );

  console.log("deployed to:", contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
