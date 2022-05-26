const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  Contract,
  utils: { defaultAbiCoder, arrayify, keccak256, parseEther },
  constants: { AddressZero },
} = require("ethers");
const {
  axelar,
  createNetwork,
  relay,
  stopAll,
  getNetwork,
  utils: { deployContract },
  setupNetwork,
  getDepositAddress,
  getFee,
  listen,
  getGasPrice,
} = require("@axelar-network/axelar-local-dev");
const MintNFTCrossChain = require("../build/MintNFTCrossChain.json");
const MCrossCollection = require("../build/MCrossCollection.json");
const Executable = require("../build/ExecutableWithToken.json");

describe("MINT NFT CROSS-CHAIN", () => {
  let chain1, chain2;
  let user1, user2;
  let mintCrossChainContract;
  let mintNftContract;
  let WETH;
  let WETH2;
  let ex1, ex2;
  beforeEach(async () => {
    chain1 = await createNetwork({
      seed: 1,
      name: "Avalanche",
      chainId: 1111,
    });
    chain2 = await createNetwork({ seed: 2, name: "Ethereum", chainId: 2222 });

    [user1] = chain1.userWallets;
    [user2] = chain2.userWallets;

    const name = "WETH";
    const symbol = "WETH";
    const decimals = 6;
    const cap = BigInt(9999999999999999999);
    WETH = await chain1.deployToken(name, symbol, decimals, cap);
    WETH2 = await chain2.deployToken(name, symbol, decimals, cap);

    mintNftContract = await deployContract(user2, MCrossCollection, [
      "MCROSS COLLECTION",
      "MCROSS",
      "TEST",
      chain2.gateway.address,
    ]);

    mintCrossChainContract = await deployContract(user1, MintNFTCrossChain, [
      chain1.gateway.address,
      chain1.gasReceiver.address,
      WETH.address,
      mintNftContract.address,
      "Ethereum",
    ]);

    await mintCrossChainContract.deployTransaction.wait();
  });

  it("should mint 1 NFT by Cross Chain", async () => {
    const amount = BigInt(1e8);

    await chain1.giveToken(user1.address, "WETH", amount);
    await chain1.giveToken(user1.address, "UST", amount);

    const totalGasLimit = (2850000 * 1).toString();

    await (
      await WETH.connect(user1).approve(mintCrossChainContract.address, amount)
    ).wait();

    await mintCrossChainContract.mint(1, {
      value: 1e8,
      gasLimit: totalGasLimit,
    });

    console.log(await WETH.balanceOf(user1.address));
    console.log(await chain1.ust.balanceOf(user1.address));
  });

  describe("send token", async () => {
    it("should send some usdc over", async () => {
      const amount = BigInt(1e8);
      const fee = BigInt(getFee(chain1, chain2, "WETH"));
      await chain1.giveToken(user1.address, "WETH", amount);
      await (
        await WETH.connect(user1).approve(chain1.gateway.address, amount)
      ).wait();
      await (
        await chain1.gateway
          .connect(user1)
          .sendToken(chain2.name, user2.address, "WETH", amount)
      ).wait();
      await relay();
      expect(await WETH2.balanceOf(user2.address)).to.equal(amount - fee);
    });
  });
});
