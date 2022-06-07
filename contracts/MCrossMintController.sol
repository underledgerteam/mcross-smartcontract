//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./axelarBridge/IMCrossBridgeToken.sol";

contract MCrossMintController is Ownable {
    using Strings for uint256;

    uint256 public costNFT = 0.022 ether;
    address public WETH;
    address bridgeAddress;

    constructor(address _weth) {
        WETH = _weth;
    }

    // Event

    event MintEvent(
        string name,
        uint256 amount,
        address from,
        address to,
        uint256 timestamp
    );

    // External Function
    function mint(uint256 _mintAmount, bytes calldata payload)
        external
        payable
    {
        uint256 total_price = _mintAmount * costNFT;
        require(IERC20(WETH).balanceOf(msg.sender) >= total_price);
        IERC20(WETH).transferFrom(msg.sender, address(this), total_price);
        IERC20(WETH).approve(bridgeAddress, total_price);

        IMCrossBridgeToken(bridgeAddress).bridge{value: msg.value}(
            total_price,
            _mintAmount,
            payload
        );

        emit MintEvent(
            string(
                abi.encodePacked("Mint", " ", _mintAmount.toString(), " " "NFT")
            ),
            costNFT * _mintAmount,
            msg.sender,
            address(this),
            block.timestamp
        );
    }

    function setCostNFT(uint256 _newCost) external onlyOwner {
        costNFT = _newCost;
    }

    function setWETHAddress(address _address) external onlyOwner {
        WETH = _address;
    }

    function setBridgeAddress(address _bridgeAddress) external onlyOwner {
        bridgeAddress = _bridgeAddress;
    }
}
