// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MCrossMarketplace is Ownable {
    enum ListingStatus {
		Active,
		Sold,
		Cancelled
	}

    uint256 private itemCount = 0;
    address public nftContract;

    // List of all market items 
	uint256[] private marketitems;

    struct MarketItem {
        address nftContract;
        uint256 tokenId;
        address owner;
        uint256 price;
        ListingStatus status;
    }

    mapping(uint256 => MarketItem) private tokenIdMarketItems;

    event List(
        address nftContract,
        uint256 tokenId,
        address owner,
        uint256 price,
        ListingStatus status
    );

    event Sale(
        address nftContract,
        uint256 tokenId,
        address owner,
        address buyer,
        uint256 price,
        ListingStatus status
    );

    event Cancel(
        uint256 tokenId,
        address owner
    );

    constructor(address _nftContract) {
        nftContract = _nftContract;
    }

    function setNftContract(address _newNFTContract) external onlyOwner {
        nftContract = _newNFTContract;
    }

    function getItemCounts() public view returns(uint256) {
        return itemCount;
    }

    function listItems(uint _tokenId, uint256 price) external {
        require(price > 0, "price must be at least 1 wei");
        require(_tokenId > 0, "token id must greater than 0");

        MarketItem memory item = tokenIdMarketItems[_tokenId];
        if(item.tokenId == _tokenId || item.status == ListingStatus.Sold){
            tokenIdMarketItems[_tokenId].price = price;
            tokenIdMarketItems[_tokenId].owner = msg.sender;
            tokenIdMarketItems[_tokenId].status = ListingStatus.Active;
        } else {
            item = MarketItem(
                nftContract,
                _tokenId,
                msg.sender,
                price,
                ListingStatus.Active
            );
            marketitems.push(_tokenId);
            tokenIdMarketItems[_tokenId] = item;
            itemCount++;
        }

        IERC721(nftContract).transferFrom(item.owner, address(this), item.tokenId);
        emit List(item.nftContract, _tokenId, msg.sender, price, item.status);
    }

    function getMarketItems() external view returns(MarketItem[] memory){
        MarketItem[] memory  items = new MarketItem[](itemCount);

        for(uint256 i = 0; i < marketitems.length; i++) {
            uint256 _tokenId = marketitems[i];
            items[i] = tokenIdMarketItems[_tokenId];
        }

        return items;
    }

    function getMyMarketplace(address _owner) external view returns(MarketItem[] memory) {
        require(msg.sender == _owner, "only owner can get my marketplace item");
        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint i = 0; i < marketitems.length; i++) {

            uint256 _tokenId = marketitems[i];

            if(
                tokenIdMarketItems[_tokenId].owner == _owner && 
                tokenIdMarketItems[_tokenId].status == ListingStatus.Active
            ){
                items[i] = tokenIdMarketItems[_tokenId];
            }
        }
        return items;
    }

    function cancelListItem(uint _tokenId) external {
        require(tokenIdMarketItems[_tokenId].tokenId > 0, "item not exists");
        MarketItem storage item = tokenIdMarketItems[_tokenId];
        
        require(item.status == ListingStatus.Active, "item must be active");
        require(msg.sender == item.owner, "cancel not allow");
        
        tokenIdMarketItems[_tokenId].status = ListingStatus.Cancelled;

        IERC721(item.nftContract).transferFrom(address(this), item.owner, item.tokenId);
        emit Cancel (_tokenId, item.owner);
    }

    function buyMarketItem(uint _tokenId) external payable {
        require(tokenIdMarketItems[_tokenId].tokenId > 0, "item not exists");
        MarketItem storage item = tokenIdMarketItems[_tokenId];

        require(msg.sender != item.owner, "buy own item not allow");
        require(item.status == ListingStatus.Active, "item status is not active");
        require(msg.value == item.price, "invalid price");

        tokenIdMarketItems[_tokenId].status = ListingStatus.Sold;

        IERC721(nftContract).transferFrom(address(this), msg.sender, item.tokenId);
        payable(item.owner).transfer(item.price);

        emit Sale(
            item.nftContract,
            item.tokenId,
            item.owner,
            msg.sender,
            item.price,
            item.status
        );
    }
}