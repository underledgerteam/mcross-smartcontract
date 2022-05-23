//SPDX-License-Identifier : MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IAxelarExecutable} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarExecutable.sol";
import {IAxelarGasReceiver} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGasReceiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftLinker is ERC721Enumerable, IAxelarExecutable, Ownable {
    using Strings for uint256;
    mapping(uint256 => bytes) public original;
    mapping(string => string) public linkers;
    IAxelarGasReceiver gasReceiver;

    string baseURI;
    string chainName;
    string public baseExtension = ".json";

    function addLinker(string memory chain, string memory linker) external {
        linkers[chain] = linker;
    }

    constructor(
        string memory chainName_,
        address gateway,
        IAxelarGasReceiver receiver,
        string memory _initBaseURI
    ) ERC721("MCROSS COLLECTION", "MCROSS") IAxelarExecutable(gateway) {
        chainName = chainName_;
        gasReceiver = receiver;
        setBaseURI(_initBaseURI);
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
        uint256 tokenId,
        string memory destinationChain,
        address destinationAddress,
        uint256 amountFree
    ) external payable {
        _sendMintedToken(
            tokenId,
            destinationChain,
            destinationAddress,
            amountFree
        );
    }

    function _sendMintedToken(
        uint256 tokenId,
        string memory destinationChain,
        address destinationAddress,
        uint256 amoutFree
    ) internal {
        _burn(tokenId);
        string memory originalChain;
        address operator;
        uint256 originalTokenId;
        (originalChain, operator, originalTokenId) = abi.decode(
            original[tokenId],
            (string, address, uint256)
        );
        bytes memory payload = abi.encode(
            originalChain,
            operator,
            originalTokenId,
            destinationAddress,
            msg.sender
        );

        uint256 totalNet = msg.value - amoutFree;

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
            originalTokenId,
            msg.sender,
            destinationAddress,
            block.timestamp
        );
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setBaseURI(string memory _newBaseURI) public {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
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
        bytes memory originalData = abi.encode(
            originalChain,
            operator,
            tokenId
        );
        uint256 newTokenId = tokenId;
        original[newTokenId] = originalData;
        _safeMint(destinationAddress, newTokenId);

        emit ReceiveNFT(sourceChain, tokenId, senderAddress, block.timestamp);
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }
}
