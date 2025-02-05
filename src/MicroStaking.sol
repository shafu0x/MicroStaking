// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {Owned} from "lib/solmate/src/auth/Owned.sol";

contract Token is ERC20("shafu Token", "ST", 18), Owned(msg.sender) {
    function mint(address to,   uint amount) external onlyOwner { _mint(to,   amount); }
    function burn(address from, uint amount) external onlyOwner { _burn(from, amount); }
}

contract MicroStaking {
    Token public token;

    uint public lastUpdate;
    uint public rewardPerShare;
    uint public ratePerSecond;

    mapping(address => uint) public debt;
    mapping(address => uint) public staked;

    modifier update() {
        uint timeElapsed = block.timestamp - lastUpdate;
        lastUpdate       = block.timestamp;
        uint minted      = timeElapsed * ratePerSecond;
        uint totalStaked = token.balanceOf(address(this));
        if (totalStaked > 0) rewardPerShare += (minted * 1e18) / totalStaked; 
        uint rewards = staked[msg.sender] * rewardPerShare / 1e18 - debt[msg.sender];
        token.mint(msg.sender, rewards);
        _;
    }

    constructor(Token _token) { 
        token         = _token; 
        lastUpdate    = block.timestamp;
        ratePerSecond = 10e18;
    }

    function stake(uint amount) external update {
        token.transferFrom(msg.sender, address(this), amount);
        staked[msg.sender] += amount;
        debt  [msg.sender] = staked[msg.sender] * rewardPerShare / 1e18;
    }

    function unstake() external update {
        token.transfer(msg.sender, staked[msg.sender]);
        debt  [msg.sender] = staked[msg.sender] * rewardPerShare / 1e18;
        staked[msg.sender] = 0;
    }
}
