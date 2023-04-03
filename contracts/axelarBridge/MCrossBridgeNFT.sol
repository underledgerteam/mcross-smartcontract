//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;
import { IAxelarExecutable } from "@axelar-network/axelar-cgp-solidity/contracts/interfaces/IAxelarExecutable.sol";
import { IAxelarGasService } from "@axelar-network/axelar-cgp-solidity/contracts/interfaces/IAxelarGasService.sol";
import "./IMCrossBridgeNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MCrossBrdigeNFT is IAxelarExecutable, Ownable, IMCrossBridgeNFT {
    IAxelarGasService public immutable gasService;

    struct SiblingData {
        uint128 chainId;
        string chainName;
        string bridgeAddress;
    }

    mapping(uint128 => SiblingData) public siblings;
    mapping(string => string) public linkers;

    constructor(
        address _gateway,
        address _gasService,
        address _controller
    ) IAxelarExecutable(_gateway) IMCrossBridgeNFT(_controller) {
        gasService = IAxelarGasService(_gasService);
    }

    function addLinker(string memory chain, string memory linker)
        public
        onlyOwner
    {
        linkers[chain] = linker;
    }

    function addSibling(
        uint128 chainId,
        string memory chainName,
        string memory bridgeAddress
    ) public onlyOwner {
        siblings[chainId] = SiblingData({
            chainId: chainId,
            chainName: chainName,
            bridgeAddress: bridgeAddress
        });
    }

    function _bridgeAxelar(
        address from,
        string memory destinationChain,
        string memory destinationAddress,
        bytes calldata payload
    ) internal {
        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            from
        );

        gateway.callContract(destinationChain, destinationAddress, payload);
    }

    function _bridge(
        uint128 chainId, //Destination Chain
        address from,
        bytes calldata payload
    ) internal override {
        require(msg.sender == address(controller), "Only Controller Call");
        _bridgeAxelar(
            from,
            siblings[chainId].chainName,
            siblings[chainId].bridgeAddress,
            payload
        );
    }

    function _execute(
        string memory sourceChain,
        string memory sourceAddress,
        bytes calldata payload
    ) internal override {
        require(
            keccak256(bytes(sourceAddress)) ==
                keccak256(bytes(linkers[sourceChain])),
            "NOT_A_LINKER"
        );

        (bool success, bytes memory returndata) = address(controller).call(
            payload
        );

        require(success, string(returndata));
    }
}
