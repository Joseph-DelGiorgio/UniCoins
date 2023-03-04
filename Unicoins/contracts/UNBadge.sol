// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract UNBadge is ERC721 {

    struct BadgeMetadata {
        uint256 lifetimeContribution;
        uint256 projectManagerFeedbackRating;
    }

    mapping(uint256 => BadgeMetadata) private _badgeMetadata;

    constructor() ERC721("UNBadge", "UNB") {}

    function mint(address recipient, uint256 tokenId, uint256 lifetimeContribution, uint256 feedbackRating) public {
        _badgeMetadata[tokenId] = BadgeMetadata(lifetimeContribution, feedbackRating);
        _mint(recipient, tokenId);
    }

    function getLifetimeContribution(uint256 tokenId) public view returns (uint256) {
        return _badgeMetadata[tokenId].lifetimeContribution;
    }

    function getFeedbackRating(uint256 tokenId) public view returns (uint256) {
        return _badgeMetadata[tokenId].projectManagerFeedbackRating;
    }
}
