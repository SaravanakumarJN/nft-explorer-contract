// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTMarketplace is Ownable {
    using SafeMath for uint256;

    ERC721 public nftContract;
    uint256 public feePercentage;

    struct Sale {
        address seller;
        uint256 price;
        bool isActive;
    }

    Sale[] public sales;

    event SaleCreated(address seller, uint256 saleIndex, uint256 price);
    event SaleCancelled(uint256 saleIndex);
    event SaleSold(
        uint256 saleIndex,
        address buyer,
        uint256 salePrice,
        uint256 fee
    );

    constructor(address _nftContract, uint256 _feePercentage) {
        nftContract = ERC721(_nftContract);
        feePercentage = _feePercentage;
    }

    function createSale(uint256 tokenId, uint256 price) external {
        require(
            nftContract.ownerOf(tokenId) == msg.sender,
            "You do not own this token"
        );
        require(price > 0, "Price must be greater than 0");
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
        uint256 saleIndex = sales.length;
        sales.push(Sale({seller: msg.sender, price: price, isActive: true}));
        emit SaleCreated(msg.sender, saleIndex, price);
    }

    function cancelSale(uint256 saleIndex) external {
        Sale storage sale = sales[saleIndex];
        require(
            msg.sender == sale.seller,
            "You are not the seller of this sale"
        );
        require(sale.isActive, "This sale is not active");
        nftContract.safeTransferFrom(
            address(this),
            msg.sender,
            nftContract.tokenOfOwnerByIndex(msg.sender, 0)
        );
        sale.isActive = false;
        emit SaleCancelled(saleIndex);
    }

    function buySale(uint256 saleIndex) external payable {
        Sale storage sale = sales[saleIndex];
        require(sale.isActive, "This sale is not active");
        require(msg.value == sale.price, "Incorrect price");
        uint256 fee = sale.price.mul(feePercentage).div(100);
        uint256 salePrice = sale.price.sub(fee);
        address payable seller = payable(sale.seller);
        seller.transfer(salePrice);
        payable(owner()).transfer(fee);
        nftContract.safeTransferFrom(
            address(this),
            msg.sender,
            nftContract.tokenOfOwnerByIndex(sale.seller, 0)
        );
        sale.isActive = false;
        emit SaleSold(saleIndex, msg.sender, salePrice, fee);
    }

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        feePercentage = _feePercentage;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
