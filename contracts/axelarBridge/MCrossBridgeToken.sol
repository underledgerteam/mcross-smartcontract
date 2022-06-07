//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAxelarGateway} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGateway.sol";
import {IAxelarGasReceiver} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGasReceiver.sol";

import "./IMCrossBridgeToken.sol";

contract MCrossBridgeToken is Ownable, IMCrossBridgeToken {
    IAxelarGateway axelarGateway;
    IAxelarGasReceiver gasReceiver;
    address public WETH;

    mapping(string => string) public destinaionChain;

    constructor(
        address _weth,
        address _gateway,
        address _gasReceiver,
        address _controller
    ) IMCrossBridgeToken(_controller) {
        axelarGateway = IAxelarGateway(_gateway);
        gasReceiver = IAxelarGasReceiver(_gasReceiver);
        WETH = _weth;
    }

    event MintEvent(
        string name,
        uint256 amount,
        address from,
        address to,
        uint256 timestamp
    );

    // Public Function
    function setDestinaionChain(
        string memory _chainName,
        string memory _destinationAddress
    ) public onlyOwner {
        destinaionChain[_chainName] = _destinationAddress;
    }

    // Internal Function
    function _mintAxelar(
        uint256 amount,
        uint256 mintAmount,
        bytes calldata _payload
    ) internal {
        string memory _destinationChain;
        address minter;

        (_destinationChain, minter) = abi.decode(_payload, (string, address));

        require(
            bytes(destinaionChain[_destinationChain]).length > 0,
            "Not Support this Chain Name"
        );

        bytes memory payload = abi.encode(minter, mintAmount);

        IERC20(WETH).transferFrom(msg.sender, address(this), amount);
        IERC20(WETH).approve(address(axelarGateway), amount);
        IERC20(WETH).approve(address(gasReceiver), amount);

        gasReceiver.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            _destinationChain,
            destinaionChain[_destinationChain],
            payload,
            "WETH",
            amount,
            minter
        );

        axelarGateway.callContractWithToken(
            _destinationChain,
            destinaionChain[_destinationChain],
            payload,
            "WETH",
            amount
        );
    }

    function _bridge(
        uint256 amount,
        uint256 mintAmount,
        bytes calldata payload
    ) internal override {
        require(msg.sender == address(controller), "Only Controller Call");
        _mintAxelar(amount, mintAmount, payload);
    }
}
