// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//import "diamond-2/deployDiamond.t.sol";
import "../contracts/facets/AuctionFacet.sol";
import "../contracts/AUCTokens.sol";

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";

import "../contracts/facets/ERC20Facet.sol";

import "forge-std/Test.sol";
import "../contracts/Diamond.sol";

import "../contracts/libraries/LibAppStorage.sol";

contract DeployAuctionDiamond is DeployDiamond {
    address public aucTokenAddress;

    function deploy() public {
        AUCTokens aucToken = new AUCTokens();
        aucTokenAddress = address(aucToken);

        address[] memory facets = new address[](1);
        facets[0] = address(new Auction(address(this), aucTokenAddress));

        LibDiamond.DiamondArgs memory args = LibDiamond.DiamondArgs({
            facets: facets,
            owner: msg.sender,
            data: ""
        });

        _deployDiamond(args);
    }

    function getAucTokenAddress() public view returns (address) {
        return aucTokenAddress;
    }
}

contract DeployAuctionDiamondTest {
    DeployAuctionDiamond deployer;
    address public diamondAddress;

    function setUp() public {
        deployer = new DeployAuctionDiamond();
    }

    function testDeploy() public {
        deployer.deploy();
        diamondAddress = deployer.deployedAddress();
        assertTrue(diamondAddress != address(0), "Deployment failed");
    }

    function testAucTokenAddress() public {
        address aucTokenAddress = deployer.getAucTokenAddress();
        assertTrue(aucTokenAddress != address(0), "AUCToken address not set");
    }
}
