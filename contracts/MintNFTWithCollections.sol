// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Collection {
        string name;
        string symbol;
        address owner;
        uint256[] tokenIds;
    }

    mapping(uint256 => uint256) private _tokenCollection;
    mapping(uint256 => Collection) private _collections;
    uint256 private _collectionId;

    constructor() ERC721("MyNFT", "MNFT") {}

    function createCollection(string memory name, string memory symbol) public {
        _collectionId++;
        _collections[_collectionId] = Collection(
            name,
            symbol,
            msg.sender,
            new uint256[](0)
        );
    }

    function mintNFT(
        uint256 collectionId,
        address recipient,
        string memory tokenURI
    ) public returns (uint256) {
        require(
            _collections[collectionId].owner == msg.sender,
            "Only collection owner can mint NFT"
        );

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _collections[collectionId].tokenIds.push(newItemId);
        _tokenCollection[newItemId] = collectionId;

        return newItemId;
    }

    function getCollectionName(
        uint256 collectionId
    ) public view returns (string memory) {
        return _collections[collectionId].name;
    }

    function getCollectionSymbol(
        uint256 collectionId
    ) public view returns (string memory) {
        return _collections[collectionId].symbol;
    }

    function getCollectionOwner(
        uint256 collectionId
    ) public view returns (address) {
        return _collections[collectionId].owner;
    }

    function getCollectionTokenIds(
        uint256 collectionId
    ) public view returns (uint256[] memory) {
        return _collections[collectionId].tokenIds;
    }

    function getCollectionId(uint256 tokenId) public view returns (uint256) {
        return _tokenCollection[tokenId];
    }
}
