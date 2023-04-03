//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAxelarExecutable } from "@axelar-network/axelar-cgp-solidity/contracts/interfaces/IAxelarExecutable.sol";
import "../Interfaces/IMCross-NFT.sol";

contract MCrossReceiveToken is Ownable, IAxelarExecutable {
    struct SiblingData {
        string chainName;
        string bridgeAddress;
    }
    address public WETH;
    address public NFT;

    mapping(string => SiblingData) public siblings;

    constructor(
        address _weth,
        address _gateway,
        address _nft
    ) IAxelarExecutable(_gateway) {
        WETH = _weth;
        NFT = _nft;
    }

    function addSibling(string memory chainName, string memory bridgeAddress)
        public
        onlyOwner
    {
        siblings[chainName] = SiblingData({
            chainName: chainName,
            bridgeAddress: bridgeAddress
        });
    }

    function _executeWithToken(
        string memory sourceChain,
        string memory sourceAddress,
        bytes calldata payload,
        string memory,
        uint256 amount
    ) internal virtual override {
        require(
            keccak256(bytes(sourceAddress)) ==
                keccak256(bytes(siblings[sourceChain].bridgeAddress)),
            "SENDER WRONG ADDRESS"
        );
        address minter;
        uint256 mintAmount;
        (minter, mintAmount) = abi.decode(payload, (address, uint256));

        IERC20(WETH).approve(NFT, amount);

        IMCrossNFT(NFT).crossMint(minter, mintAmount, address(this), amount);
    }
}
