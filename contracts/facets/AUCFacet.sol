// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* AUC Facet for auction functionality.
/******************************************************************************/


import {LibAuction} from "../libraries/LibAuction.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract AUCFacet {
    using EnumerableSet for EnumerableSet.UintSet;

    event BidPlaced(address indexed bidder, uint256 amount);
    event BidWithdrawn(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    struct Auction {
        address highestBidder;
        uint256 highestBid;
        uint256 endTime;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(address => EnumerableSet.UintSet) internal _userBids;

    function placeBid(uint256 _tokenId) external payable {
        LibAuction.Auction storage auction = auctions[_tokenId];
        require(auction.endTime > block.timestamp, "AUC: Auction ended");
        require(msg.value > auction.highestBid, "AUC: Bid not high enough");

        address previousBidder = auction.highestBidder;
        uint256 previousBid = auction.highestBid;

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;

        if (previousBidder != address(0)) {
            LibDiamond.enforceHasContractCode(previousBidder);
            (bool success, ) = previousBidder.call{value: previousBid}("");
            require(success, "AUC: Failed to send previous bid");
        }

        emit BidPlaced(msg.sender, msg.value);

        if (previousBid > 0) {
            LibDiamond.enforceHasContractCode(previousBidder);
            (bool success, ) = previousBidder.call{value: previousBid}("");
            require(success, "AUC: Failed to send previous bid");
            payable(msg.sender).transfer(previousBid);
            emit BidWithdrawn(previousBidder, previousBid);
        }

        _userBids[msg.sender].add(_tokenId);
    }

    function withdrawBid(uint256 _tokenId) external {
        LibAuction.Auction storage auction = auctions[_tokenId];
        require(
            auction.endTime < block.timestamp,
            "AUC: Auction not ended yet"
        );
        require(
            msg.sender == auction.highestBidder,
            "AUC: Not the highest bidder"
        );

        uint256 amount = auction.highestBid;
        delete auctions[_tokenId];

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "AUC: Withdraw failed");

        emit BidWithdrawn(msg.sender, amount);

        _userBids[msg.sender].remove(_tokenId);
    }

    function endAuction(uint256 _tokenId) external {
        LibAuction.Auction storage auction = auctions[_tokenId];
        require(
            auction.endTime < block.timestamp,
            "AUC: Auction not ended yet"
        );

        address winner = auction.highestBidder;
        uint256 amount = auction.highestBid;

        delete auctions[_tokenId];

        (bool success, ) = winner.call{value: amount}("");
        require(success, "AUC: Transfer failed");

        emit AuctionEnded(winner, amount);
    }

    function getUserBids(address _user)
        external
        view
        returns (uint256[] memory)
    {
        EnumerableSet.UintSet storage userBids = _userBids[_user];
        uint256[] memory result = new uint256[](userBids.length());
        for (uint256 i = 0; i < userBids.length(); i++) {
            result[i] = userBids.at(i);
        }
        return result;
    }
}

