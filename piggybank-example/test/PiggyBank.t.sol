// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PiggyBank.sol";

contract PiggyBankTest is Test {
    PiggyBank piggy;
    address user = address(1);

    function setUp() public {
        piggy = new PiggyBank();
        vm.deal(user, 10 ether);
    }

    function testDepositAndWithdraw() public {
        vm.prank(user);
        piggy.deposit{value: 1 ether}();
        assertEq(piggy.balances(user), 1 ether);

        vm.prank(user);
        piggy.withdraw(0.5 ether);
        assertEq(piggy.balances(user), 0.5 ether);
    }
} 