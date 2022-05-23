//SPDX-License-Identifier : MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IAxelarExecutable} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarExecutable.sol";
import {IAxelarGasReceiver} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGasReceiver.sol";

contract ConverseNFTETH is IAxelarExecutable, Ownable {
    using Strings for uint256;
    mapping(string => string) public linkers;
    IAxelarGasReceiver gasReceiver;

    string public chainName;

    function addLinker(string memory chain, string memory linker) external {
        linkers[chain] = linker;
    }

    constructor(
        string memory chainName_,
        address gateway,
        IAxelarGasReceiver receiver
    ) IAxelarExecutable(gateway) {
        chainName = chainName_;
        gasReceiver = receiver;
    }

    event ConverseNFT(
        string fromChain,
        string toChain,
        uint256 tokenId,
        address sourceAddress,
        address destinationAddress,
        uint256 date
    );

    event ReceiveNFT(
        string fromChain,
        uint256 tokenId,
        address fromAddress,
        uint256 date
    );

    function sendNFT(
        address operator,
        uint256 tokenId,
        string memory destinationChain,
        address destinationAddress,
        uint256 amountFree
    ) external payable {
        IERC721(operator).transferFrom(msg.sender, address(this), tokenId);
        _sendNativeToken(
            operator,
            tokenId,
            destinationChain,
            destinationAddress,
            amountFree
        );
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _sendNativeToken(
        address operator,
        uint256 tokenId,
        string memory destinationChain,
        address destinationAddress,
        uint256 amoutFree
    ) internal {
        uint256 totalNet = msg.value - amoutFree;

        bytes memory payload = abi.encode(
            chainName,
            operator,
            tokenId,
            destinationAddress,
            msg.sender
        );

        gasReceiver.payNativeGasForContractCall{value: totalNet}(
            address(this),
            destinationChain,
            linkers[destinationChain],
            payload,
            msg.sender
        );

        gateway.callContract(
            destinationChain,
            linkers[destinationChain],
            payload
        );

        emit ConverseNFT(
            chainName,
            destinationChain,
            tokenId,
            msg.sender,
            destinationAddress,
            block.timestamp
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
        string memory originalChain;
        address operator;
        uint256 tokenId;
        address destinationAddress;
        address senderAddress;
        (
            originalChain,
            operator,
            tokenId,
            destinationAddress,
            senderAddress
        ) = abi.decode(payload, (string, address, uint256, address, address));

        IERC721(operator).transferFrom(
            address(this),
            destinationAddress,
            tokenId
        );

        emit ReceiveNFT(sourceChain, tokenId, senderAddress, block.timestamp);
    }
}
