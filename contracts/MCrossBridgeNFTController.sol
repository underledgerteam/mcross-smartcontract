//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./axelarBridge/IMCrossBridgeNFT.sol";
import "./Interfaces/IMockCollection.sol";

contract MCrossBridgeNFTController is Ownable {
    string public chainName;
    address public nftAddress;
    address public bridgeAddress;
    address public mockNFT;

    mapping(address => bool) public registerBridge;

    //External Function

    // Public Function
    function setNftAddress(address _address) public onlyOwner {
        nftAddress = _address;
    }

    function setDestinatiomNftAddress(address _address) public onlyOwner {
        mockNFT = _address;
    }

    function setChainName(string memory _name) public onlyOwner {
        chainName = _name;
    }

    function setBridgeAddress(address _address) public onlyOwner {
        bridgeAddress = _address;
    }

    function setRegisterBridge(address _address) public onlyOwner {
        registerBridge[_address] = true;
    }

    function unlock(uint128 chainId, bytes calldata payload) external {
        require(registerBridge[msg.sender], "Only Bridge Contract can caller");
        address minter;
        uint256 tokenId;
        (minter, tokenId) = abi.decode(payload, (address, uint256));
        if (keccak256(bytes(chainName)) == keccak256(bytes("Ethereum"))) {
            IERC721(nftAddress).safeTransferFrom(
                address(this),
                minter,
                tokenId
            );
        } else {
            IMockCollection(mockNFT).mintToken(minter, tokenId);
        }
    }

    function bridge(
        uint128 chainId,
        uint256 tokenId,
        uint256 amountFree,
        bytes calldata header
    ) public payable {
        if (keccak256(bytes(chainName)) == keccak256(bytes("Ethereum"))) {
            _lock(tokenId);
        } else {
            IMockCollection(mockNFT).burnToken(tokenId);
        }
        uint256 totalNet = msg.value - amountFree;
        bytes memory payload = abi.encode(msg.sender, tokenId);

        IMCrossBridgeNFT(bridgeAddress).bridge{value: totalNet}(
            chainId, //Destination
            msg.sender,
            abi.encodeWithSelector(
                MCrossBridgeNFTController(address(this)).unlock.selector,
                chainId,
                payload
            )
        );
    }

    // Internal Function
    function _lock(uint256 tokenId) internal {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);
    }
}
