// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAxelarGateway} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGateway.sol";
import {IAxelarGasReceiver} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGasReceiver.sol";

contract MintNFTCrossChain is Ownable {
    using Strings for uint256;

    IAxelarGateway axelarGateway;
    IAxelarGasReceiver gasReceiver;
    string public destinationAddress;
    string public destinationChain;
    address public tokenAddress;
    uint256 public costNFT = 0.022 ether;
    address public axelarGatewayAddress;
    address gasReceiverAddress;

    constructor(
        address _gateway,
        address _gasReceiver,
        address _tokenAddress,
        string memory _destinationAddress,
        string memory _destinationChain
    ) {
        axelarGateway = IAxelarGateway(_gateway);
        gasReceiver = IAxelarGasReceiver(_gasReceiver);
        tokenAddress = _tokenAddress;
        axelarGatewayAddress = _gateway;
        gasReceiverAddress = _gasReceiver;
        destinationAddress = _destinationAddress;
        destinationChain = _destinationChain;
    }

    event MintEvent(
        string name,
        uint256 amount,
        address from,
        address to,
        uint256 timestamp
    );

    function setDestinationAddress(string memory _newAddress)
        external
        onlyOwner
    {
        destinationAddress = _newAddress;
    }

    function setDestinationChain(string memory _newChain) external onlyOwner {
        destinationChain = _newChain;
    }

    function setTokenAddress(address _newAddress) external onlyOwner {
        tokenAddress = _newAddress;
    }

    function setCostNFT(uint256 _newCost) external onlyOwner {
        costNFT = _newCost;
    }

    function mint(uint256 _mintAmount) external payable {
        uint256 total = _mintAmount * costNFT;

        require(IERC20(tokenAddress).balanceOf(msg.sender) >= total);

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), total);
        IERC20(tokenAddress).approve(axelarGatewayAddress, total);
        IERC20(tokenAddress).approve(gasReceiverAddress, total);

        bytes memory payload = abi.encode(msg.sender, _mintAmount);

        gasReceiver.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            "WETH",
            total,
            msg.sender
        );

        axelarGateway.callContractWithToken(
            destinationChain,
            destinationAddress,
            payload,
            "WETH",
            total
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
}
