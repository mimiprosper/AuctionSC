// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibAuction {
    struct Auction {
        address token; // Address of the ERC721 or ERC1155 token being auctioned
        uint256 tokenId; // ID of the token being auctioned
        address payable seller; // Address of the seller
        address payable highestBidder; // Address of the highest bidder
        uint256 startTime; // Start time of the auction
        uint256 endTime; // End time of the auction
        uint256 startPrice; // Starting price of the auction
        uint256 minBidIncrement; // Minimum bid increment
        uint256 highestBid; // Highest bid amount
        uint256 totalBids; // Total number of bids
        bool finalized; // Flag indicating whether the auction is finalized
    }

    struct Incentives {
        uint256 burn;
        uint256 dao;
        uint256 outbid;
        uint256 team;
        uint256 lastInteracted;
    }

    function initialize(
        Auction storage self,
        address _token,
        uint256 _tokenId,
        address payable _seller,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _startPrice,
        uint256 _minBidIncrement
    ) internal {
        require(_token != address(0), "LibAuction: Token address cannot be zero");
        require(_seller != address(0), "LibAuction: Seller address cannot be zero");
        require(_endTime > _startTime, "LibAuction: End time must be after start time");
        require(_startPrice > 0, "LibAuction: Start price must be greater than zero");
        require(_minBidIncrement > 0, "LibAuction: Minimum bid increment must be greater than zero");

        self.token = _token;
        self.tokenId = _tokenId;
        self.seller = _seller;
        self.startTime = _startTime;
        self.endTime = _endTime;
        self.startPrice = _startPrice;
        self.minBidIncrement = _minBidIncrement;
        self.highestBid = _startPrice;
    }

    function bid(Auction storage self, address payable _bidder, uint256 _amount) internal {
        require(!_isEnded(self), "LibAuction: Auction ended");
        require(_amount >= self.highestBid + self.minBidIncrement, "LibAuction: Bid amount too low");

        self.highestBidder.transfer(self.highestBid); // Refund previous highest bidder
        self.highestBidder = _bidder;
        self.highestBid = _amount;
        self.totalBids++;
    }

    function calculateIncentives(uint256 totalFee) internal pure returns (Incentives memory) {
        uint256 burn = totalFee * 2 / 100; // 2% burn
        uint256 dao = totalFee * 2 / 100; // 2% to random DAO address
        uint256 outbid = totalFee * 3 / 100; // 3% goes back to the outbid bidder
        uint256 team = totalFee * 2 / 100; // 2% goes to the team wallet
        uint256 lastInteracted = totalFee * 1 / 100; // 1% goes to the last address to interact

        return Incentives(burn, dao, outbid, team, lastInteracted);
    }


    function finalize(Auction storage self) internal {
        require(_isEnded(self), "LibAuction: Auction not ended");
        require(!self.finalized, "LibAuction: Auction already finalized");

        self.finalized = true;
        if (self.highestBid > 0) {
            self.seller.transfer(self.highestBid); // Transfer highest bid amount to seller
        }
    }

    function _isEnded(Auction storage self) private view returns (bool) {
        return block.timestamp >= self.endTime;
    }
}

