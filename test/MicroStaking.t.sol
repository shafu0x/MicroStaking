// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

import "forge-std/Test.sol";

import {Token, MicroStaking} from "../src/MicroStaking.sol";

contract MicroStaking_Test is Test {
    Token        token;
    MicroStaking staking;

    address bob;
    address alice;

    function setUp() public {
        token   = new Token();
        staking = new MicroStaking(token);
        token.transferOwnership(address(staking));

        bob   = makeAddr("bob");
        alice = makeAddr("alice");
    }

    function test_staking() public {
        uint bobAmount   = 100e18;
        uint aliceAmount = 100e18;

        deal(address(token), bob,   bobAmount);
        deal(address(token), alice, aliceAmount);

        vm.startPrank(bob);
        token.approve(address(staking), bobAmount);
        staking.stake(bobAmount);
        vm.stopPrank();

        vm.startPrank(alice);
        token.approve(address(staking), aliceAmount);
        staking.stake(aliceAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + 1 days);

        vm.prank(bob);
        staking.unstake();
        assertTrue(token.balanceOf(bob) > bobAmount);

        vm.prank(alice);
        staking.unstake();
        assertTrue(token.balanceOf(alice) > aliceAmount);

        console.log(token.balanceOf(bob));
        console.log(token.balanceOf(alice));
    }

    function test_staking_differentTimes() public {
        uint bobAmount   = 100e18;
        uint aliceAmount = 100e18;

        deal(address(token), bob,   bobAmount);
        deal(address(token), alice, aliceAmount);

        vm.startPrank(bob);
        token.approve(address(staking), bobAmount);
        staking.stake(bobAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + 1 days);

        vm.startPrank(alice);
        token.approve(address(staking), aliceAmount);
        staking.stake(aliceAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + 1 days);

        vm.prank(bob);
        staking.unstake();

        vm.prank(alice);
        staking.unstake();

        console.log(token.balanceOf(bob));
        console.log(token.balanceOf(alice));
    }
}