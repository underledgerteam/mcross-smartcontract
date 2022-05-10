//SPDX-License-Identifier : MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAxelarGateway} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGateway.sol";
import {IAxelarGasReceiver} from "@axelar-network/axelar-cgp-solidity/src/interfaces/IAxelarGasReceiver.sol";

contract NftLinker is ERC721, IAxelarExecutable {
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
    ) ERC721("Wrapped Worm", "WWORM") IAxelarExecutable(gateway) {
        chainName = chainName_;
        gasReceiver = receiver;
        setBaseURI(_initBaseURI);
    }

    function sendNFT(
        address operator,
        uint256 tokenId,
        string memory destinationChain,
        address destinationAddress
    ) external payable {
        if (operator == address(this)) {
            _sendMintedToken(tokenId, destinationChain, destinationAddress);
        } else {
            IERC721(operator).transferFrom(
                _msgSender(),
                address(this),
                tokenId
            );
            _sendNativeToken(
                operator,
                tokenId,
                destinationChain,
                destinationAddress
            );
        }
    }

    function _sendMintedToken(
        uint256 tokenId,
        string memory destinationChain,
        address destinationAddress
    ) internal {
        _burn(tokenId);
        string memory originalChain;
        address operator;
        uint256 originalTokenId;
        (originalChain, operator, tokenId) = abi.decode(
            original[tokenId],
            (string, address, uint256)
        );
        bytes memory payload = abi.encode(
            originalChain,
            operator,
            originalTokenId,
            destinationAddress
        );
        gateway.callContract(
            destinationChain,
            linkers[destinationChain],
            payload
        );
    }

    function _sendNativeToken(
        address operator,
        uint256 tokenId,
        string memory destinationChain,
        address destinationAddress
    ) internal {
        bytes memory payload = abi.encode(
            chainName,
            operator,
            tokenId,
            destinationAddress
        );

        gasReceiver.payNativeGasForContractCall{value: msg.value}(
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
        (originalChain, operator, tokenId, destinationAddress) = abi.decode(
            payload,
            (string, address, uint256, address)
        );
        bytes memory originalData = abi.encode(
            originalChain,
            operator,
            tokenId
        );
        if (keccak256(bytes(originalChain)) == keccak256(bytes(chainName))) {
            IERC721(operator).transferFrom(
                address(this),
                destinationAddress,
                tokenId
            );
        } else {
            uint256 newTokenId = tokenId;
            original[newTokenId] = originalData;
            _safeMint(destinationAddress, newTokenId);
        }
    }
}
