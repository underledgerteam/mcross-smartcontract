const { ethers } = require("hardhat");

async function main() {
    const axelarGatewayAddress = "";
    const axelarGasServiceAddress = "";
    const wethAddress = ""; 

    // Bridge Controller
    const MCrossBridgeNFTController = await ethers.getContractFactory(
        "MCrossBridgeNFTController"
    );
    const controllerContract = await MCrossBridgeNFTController.deploy();
    await controllerContract.deployed();

    // Mint Controller
    const MCrossMintController = await ethers.getContractFactory(
        "MCrossMintController"
    );
    const mintController = await MCrossMintController.deploy();
    await mintController.deployed(wethAddress);

    // Bridge NFT (Axelar)
    const MCrossBrdigeNFT = await await ethers.getContractFactory(
        "MCrossBrdigeNFT"
    );
    const bridgeNFTContract = await MCrossBrdigeNFT.deploy(
        axelarGatewayAddress,
        axelarGasServiceAddress,
        controllerContract.address
    );
    await bridgeNFTContract.deployed();

    // Bridge Token (Axelar)
    const MCrossBridgeToken = await ethers.getContractFactory(
        "MCrossBridgeToken"
    );
    const bridgeTokenContract = await MCrossBridgeToken.deploy();
    await bridgeTokenContract.deployed(
        wethAddress,
        axelarGatewayAddress,
        axelarGasServiceAddress,
        controllerContract.address
    );

    // Mock NFT
    const MockCollection = await ethers.getContractFactory("MockCollection");
    const nftContract = await MockCollection.deploy();
    await nftContract.deployed();

    console.log("MCrossBridgeNFTController deployed to: ", controllerContract.address);
    console.log("MCrossMintController deployed to: ", mintController.address);
    console.log("MCrossBrdigeNFT deployed to: ", bridgeNFTContract.address);
    console.log("MCrossBridgeToken deployed to: ", bridgeTokenContract.address);
    console.log("MockCollection deployed to: ", nftContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
