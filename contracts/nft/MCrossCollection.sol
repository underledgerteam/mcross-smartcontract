// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MCrossCollection is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI =
        "ipfs://QmYuooZLrfDFY1P5CSfpr5SCj2UiLejdLpJUtfxsS87L9T/";
    string public baseExtension = ".json";
    uint256 public cost = 0.02 ether;
    uint256 public maxSupply = 1000;
    uint256 public maxMintAmount = 5;
    bool public paused = false;
    address wethAddress = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    uint256 balanceWETH;
    address Owner;

    mapping(address => uint256) private userRefund;
    mapping(address => bool) private addressCanMint;

    constructor() ERC721("MCROSS COLLECTION", "MCROSS NFT") {
        Owner = msg.sender;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // external
    function mint(uint256 _mintAmount) external payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        if (msg.sender != owner()) {
            require(msg.value >= cost * _mintAmount);
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function crossMint(
        address _minter,
        uint256 _mintAmount,
        address _caller,
        uint256 _amount
    ) external {
        require(addressCanMint[_caller], "Caller can not Mint NFT");
        IERC20(wethAddress).transferFrom(msg.sender, address(this), _amount);
        uint256 supply = totalSupply();

        if (supply + _mintAmount <= maxSupply) {
            balanceWETH += _amount;
            for (uint256 i = 1; i <= _mintAmount; i++) {
                _safeMint(_minter, supply + i);
            }
        } else {
            userRefund[_minter] += _amount;
        }
    }

    function usercanRefund() external {
        require(userRefund[msg.sender] > 0);
        payable(msg.sender).transfer(userRefund[msg.sender]);
        userRefund[msg.sender] = 0;
    }

    //only owner
    function setCost(uint256 _newCost) external onlyOwner {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) external onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setWETHAddress(address _newAddress) external onlyOwner {
        wethAddress = _newAddress;
    }

    function withdrawWETH() external onlyOwner {
        IERC20(wethAddress).transfer(Owner, balanceWETH);
    }

    //Public Function

    function setAddressCanMint(address _address) public {
        addressCanMint[_address] = true;
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

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
}
