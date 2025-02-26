// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibAppStorage {
    uint256 constant APY = 120;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    struct UserStake {
        uint256 stakedTime;
        uint256 amount;
    }

    struct Layout {
        // ERC20
        string name;
        string symbol;
        uint256 totalSupply;
        uint8 decimals;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        // Staking
        address rewardToken;
        uint256 rewardRate;
        mapping(address => UserStake) userDetails;
        address[] stakers;

        bool initialized;
        uint256 currentBid; 
        address auctionToken;
        address randomDaoAddress;
        address teamWallet;
        address lastInteractedAddress;
        address currentBidder;
    }

    // struct AuctionStorage {
    //     address auctionToken;
    //     address randomDaoAddress;
    //     address teamWallet;
    //     address lastInteractedAddress;
    //     address currentBidder;
        
    // }


    function layoutStorage() internal pure returns (Layout storage l) {
        assembly {
            l.slot := 0
        }
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        Layout storage l = layoutStorage();
        uint256 frombalances = l.balances[msg.sender];
        require(
            frombalances >= _amount,
            "ERC20: Not enough tokens to transfer"
        );
        l.balances[_from] = frombalances - _amount;
        l.balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }
}
