const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MCOSS COLLECTION", () => {
  let MCOSSContract;
  let owner;
  beforeEach(async () => {
    const MCrossCollection = await ethers.getContractFactory(
      "MCrossCollection"
    );
    [owner] = await ethers.getSigners();
    MCOSSContract = await MCrossCollection.deploy(
      "MCOSS COLLECTION",
      "MCROSS",
      "ipfs://QmYuooZLrfDFY1P5CSfpr5SCj2UiLejdLpJUtfxsS87L9T/",
      "0xbc6fcce7c5487d43830a219ca6e7b83238b41e71"
    );
  });

  it("Should initialize the MCrossCollection contract", async () => {
    expect(await MCOSSContract.name()).to.equal("MCOSS COLLECTION");
  });

  it("Should mint a MCROSS", async () => {
    const Price = await MCOSSContract.cost();
    const tokenId = await MCOSSContract.totalSupply();
    expect(
      await MCOSSContract.mint(1, {
        value: Price,
      })
    )
      .to.emit(MCOSSContract, "Transfer")
      .withArgs(ethers.constants.AddressZero, owner.address, tokenId);
  });

  it("Should mint 5 MCROSS", async () => {
    const Price = await MCOSSContract.cost();
    const tokenId = await MCOSSContract.totalSupply();

    const totalPrice = ethers.utils.parseEther(
      (ethers.utils.formatEther(Price) * 5).toString()
    );
    expect(
      await MCOSSContract.mint(5, {
        value: totalPrice,
      })
    )
      .to.emit(MCOSSContract, "Transfer")
      .withArgs(ethers.constants.AddressZero, owner.address, tokenId);
  });

  it("Should fail if sender doesn't have enough eth", async () => {
    const totalPrice = ethers.utils.parseEther("0.01");
    const totalGasLimit = (285000 * 6).toString();

    await expect(
      MCOSSContract.mint(6, {
        value: totalPrice,
        gasLimit: totalGasLimit,
      })
    ).to.be.revertedWith("Transaction reverted without a reason string");
  });

  it("Should mint fail if mint amount > 5", async () => {
    const Price = await MCOSSContract.cost();
    const totalPrice = ethers.utils.parseEther(
      (ethers.utils.formatEther(Price) * 5).toString()
    );
    const totalGasLimit = (285000 * 6).toString();

    await expect(
      MCOSSContract.mint(6, {
        value: totalPrice,
        gasLimit: totalGasLimit,
      })
    ).to.be.revertedWith("Transaction reverted without a reason string");
  });
});
