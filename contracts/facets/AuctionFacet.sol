// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {LibAppStorage} from "../libraries/LibAppStorage.sol";
import {LibAuction} from "../libraries/LibAuction.sol";

contract AuctionFacet {
    using LibAppStorage for LibAppStorage.Layout;
    using LibAuction for LibAppStorage.Layout;

    uint256 constant TOTAL_FEE_PERCENTAGE = 10;

    function placeBid(uint256 _amount) external {
        LibAppStorage.Layout storage l = LibAppStorage.layoutStorage();
        require(_amount > l.currentBid, "AuctionFacet: Bid must be higher than current bid");

        // Calculate total fee and distributed incentives
        LibAuction.Incentives memory incentives = LibAuction.calculateIncentives(_amount);

        // Transfer bid amount from bidder to contract
        require(IERC20(l.auctionToken).transferFrom(msg.sender, address(this), _amount), "AuctionFacet: Transfer failed");

        // Burn tokens
        IERC20(l.auctionToken).transfer(address(0), incentives.burn);

        // Transfer tokens to DAO
        IERC20(l.auctionToken).transfer(l.randomDaoAddress, incentives.dao);

        // Transfer tokens to outbid bidder
        if (l.currentBidder != address(0)) {
            IERC20(l.auctionToken).transfer(l.currentBidder, incentives.outbid);
        }

        // Transfer tokens to team wallet
        IERC20(l.auctionToken).transfer(l.teamWallet, incentives.team);

        // Transfer tokens to last interacted address
        IERC20(l.auctionToken).transfer(l.lastInteractedAddress, incentives.lastInteracted);

        // Update current bid and bidder
        l.currentBid = _amount;
        l.currentBidder = msg.sender;
    }
}
