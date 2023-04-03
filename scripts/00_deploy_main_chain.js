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

    // Mock NFT
    const MCrossCollection = await ethers.getContractFactory("MCrossCollection");
    const nftContract = await MCrossCollection.deploy();
    await nftContract.deployed();

    // Receive Token (For Axelar)
    const MCrossReceiveToken = await ethers.getContractFactory(
        "MCrossReceiveToken"
    );
    const receiveToken = await MCrossReceiveToken.deploy();
    await receiveToken.deployed(
        wethAddress,
        axelarGatewayAddress,
        bridgeNFTContract.address
    );

    console.log("MCrossBridgeNFTController deployed to: ", controllerContract.address);
    console.log("MCrossBrdigeNFT deployed to: ", bridgeNFTContract.address);
    console.log("MCrossCollection deployed to: ", nftContract.address);
    console.log("MCrossReceiveToken deployed to: ", receiveToken.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
