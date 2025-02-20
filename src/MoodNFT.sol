// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
    error MoodNFT__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_sadSvgImageURI;
    string private s_happySvgImageURI;

    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(string memory sadSvgImageURI, string memory happySvgImageURI) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgImageURI = sadSvgImageURI;
        s_happySvgImageURI = happySvgImageURI;
    }

    function mintNFT() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        // only want the NFT owner to  be able to change the mood
        // Fetch the owner of the token
        address owner = ownerOf(tokenId);
        // Only want the owner of NFT to change the mood.
        if (_isAuthorized(owner, msg.sender, tokenId)) {
            revert MoodNFT__CantFlipMoodIfNotOwner();
        }
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;

        s_tokenIdToMood[tokenId] == Mood.HAPPY ? imageURI = s_happySvgImageURI : imageURI = s_sadSvgImageURI;

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '","description": "An NFT that reflect the owners mood.","attributes":[{"trait_type":"moodiness","value":100}],"image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
