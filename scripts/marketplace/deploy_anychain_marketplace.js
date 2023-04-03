const { ethers } = require("hardhat");

async function main() {
    // Anychain Marketplace
    const nftContractAddress = "";
    const creatorWalletAddress = "";
    const wethAddress = ""; 

    const MarketplaceAnychain = await ethers.getContractFactory(
        "MCrossMarketplace"
    );
    const marketplaceAnychain = await MarketplaceAnychain.deploy();
    await marketplaceAnychain.deployed(
        nftContractAddress,
        creatorWalletAddress,
        wethAddress
    );

    console.log("MarketplaceAnychain deployed to: ", marketplaceAnychain.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
