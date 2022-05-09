// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAxelarGateway} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGateway.sol";
import {IAxelarGasReceiver} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGasReceiver.sol";

contract MintNFTCrossChain is Ownable {
    IAxelarGateway axelarGateway;
    IAxelarGasReceiver gasReceiver;
    string destinationAddress;
    string destinationChain;
    address tokenAddress;
    uint256 costNFT = 0.022 ether;
    address axelarGatewayAddress;
    address gasReceiverAddress;

    constructor(
        address _gateway,
        address _gasReceiver,
        address _tokenAddress,
        address _destinationAddress,
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

    function setDestinationAddress(address _newAddress) external onlyOwner {
        destinationAddress = _newAddress;
    }

    function setDestinationChain(string memory _newChain) external onlyOwner {
        destinationChain = _newChain;
    }

    function setCostNFT(uint256 _newCost) external onlyOwner {
        costNFT = _newCost;
    }

    function mint(uint256 _mintAmount) public payable {
        uint256 total = _mintAmount * costNFT;

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), total);
        IERC20(tokenAddress).approve(axelarGatewayAddress, total);
        IERC20(tokenAddress).approve(gasReceiverAddress, total);

        require(IERC20.balanceOf(msg.sender >= total));

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
    }
}
