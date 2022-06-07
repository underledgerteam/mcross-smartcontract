//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;
import "../MCrossMintController.sol";

abstract contract IMCrossBridgeToken {
    MCrossMintController public immutable controller;

    constructor(address _controller) {
        controller = MCrossMintController(_controller);
    }

    modifier onlyController() {
        require(msg.sender == address(controller), "Not Controller");
        _;
    }

    function _bridge(
        uint256 amount,
        uint256 mintAmount,
        bytes calldata payload
    ) internal virtual;

    function bridge(
        uint256 amount,
        uint256 mintAmount,
        bytes calldata payload
    ) public payable onlyController {
        _bridge(amount, mintAmount, payload);
    }
}
