const { ethers } = require("hardhat");

async function main() {
    // Ethereum Marketplace
    const nftContractAddress = "";
    const creatorWalletAddress = "";

    const MarketplaceEthereum = await ethers.getContractFactory(
        "MCrossMarketplaceETH"
    );
    const marketplaceEthereum = await MarketplaceEthereum.deploy();
    await marketplaceEthereum.deployed(
        nftContractAddress,
        creatorWalletAddress
    );

    console.log("MarketplaceEthereum deployed to: ", marketplaceEthereum.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
