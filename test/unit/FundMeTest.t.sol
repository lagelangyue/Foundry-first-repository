// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import "../mocks/MockV3Aggregator.sol";

/*
1.Unit测试：测试代码中特定部分
2.Integration测试：测试代码中不同部分的交互
3.Forked测试：在本地 fork 一个真实的链，测试与真实链的交互
4.Staging测试：
    - 在本地 fork 一个真实的链，测试与真实链的交互
    - 但是在测试之前，先部署合约到真实链上
*/

contract FundMeTest is Test {
    FundMe fundMe;
    MockV3Aggregator mockPriceFeed;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant EXPECTED_CHAINLINK_VERSION = 4;

    receive() external payable {}

    // 其他测试函数执行前运行，并设置测试环境
    function setUp() public {
        mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        fundMe = new FundMe(address(mockPriceFeed));
        vm.deal(USER, 100 ether);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, EXPECTED_CHAINLINK_VERSION);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        // 先检查 array 初始为空
        vm.expectRevert(); // getFunder(0) 应该 revert（array 空）
        fundMe.getFunder(0);

        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act - 伪装成 owner 调用 withdraw
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint256 numberOfFunders = 10;
        for (uint256 i = 1; i <= numberOfFunders; i++) {
            // 创建新的地址并给它们一些 ETH
            address funder = address(uint160(i));
            vm.deal(funder, 100 ether);
            // 伪装成这个地址并调用 fund 方法
            vm.prank(funder);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act - 伪装成 owner 调用 withdraw
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, fundMe.getOwner().balance);

        // 确保所有的 funder 的资金额都被重置为 0
        for (uint256 i = 1; i <= numberOfFunders; i++) {
            address funder = address(uint160(i));
            assertEq(fundMe.getAddressToAmountFunded(funder), 0);
        }
    }
}
