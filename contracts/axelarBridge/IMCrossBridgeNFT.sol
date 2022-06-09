//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../MCrossBridgeNFTController.sol";

abstract contract IMCrossBridgeNFT {
    MCrossBridgeNFTController public immutable controller;

    constructor(address _controller) {
        controller = MCrossBridgeNFTController(_controller);
    }

    modifier onlyController() {
        require(msg.sender == address(controller), "Not Controller");
        _;
    }

    function _bridge(
        uint128 chainId,
        address from,
        bytes calldata payload
    ) internal virtual;

    function bridge(
        uint128 chainId,
        address from,
        bytes calldata payload
    ) public payable onlyController {
        _bridge(chainId, from, payload);
    }
}
