// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {MockV3Aggregator} from "../../test/mocks/MockV3Aggregator.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    MockV3Aggregator mockPriceFeed;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1; // 1 gwei

    receive() external payable {}

    function setUp() public {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run(); // 直接部署并返回 FundMe
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        // 直接用 USER prank fund
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        // 直接用 owner prank withdraw
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
    }
}
