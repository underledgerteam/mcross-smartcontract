const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CROSS-CHAIN MINT", () => {
  let MCOSSContract;
  let MockERC20Contract;
  let tester;
  beforeEach(async () => {
    const WETHMOCK = await ethers.getContractFactory("WETHMOCK");
    MockERC20Contract = await WETHMOCK.deploy();
    [tester, owner] = await ethers.getSigners();
    await MockERC20Contract.mint(tester.address, "10000000000000000000");

    const MintNFTCrossChain = await ethers.getContractFactory(
      "MintNFTCrossChain"
    );
    MCOSSContract = await MintNFTCrossChain.deploy(
      "0xBC6fcce7c5487d43830a219CA6E7B83238B41e71",
      "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
      MockERC20Contract.address,
      "0xe9D2e454968379426BB6b0a92ffaf20A60ff579d",
      "Polygon"
    );
  });

  it("Should initialize the MCOSS Contract", async () => {
    expect(await MCOSSContract.axelarGatewayAddress()).to.equal(
      "0xBC6fcce7c5487d43830a219CA6E7B83238B41e71"
    );
  });

  it("Should mint a MCROSS Crosschain", async () => {
    const Price = await MCOSSContract.costNFT();
    await MockERC20Contract.connect(tester).approve(
      MCOSSContract.address,
      "100000000000000000000"
    );
    expect(
      await MCOSSContract.mint(1, {
        value: Price,
      })
    ).to.be.reverted;
  });
});
