### MicroStaking

MicroStaking is a minimalistic staking contract that allows users to stake a custom ERC20 token, earn rewards over time, and then unstake their tokens. It uses the Solmate library for streamlined ERC20 and ownership functionality.

## Overview

- **Stake** tokens to earn yield over time.
- **Mint** new reward tokens automatically, based on a fixed rate set at contract deployment.
- **Unstake** at any time (in this version, fully unstaking all tokens).

## How It Works

1. **Reward Rate**  
   A fixed `ratePerSecond` determines how many tokens are minted per second in total.

2. **rewardPerShare Tracking**

   - Every time someone calls `stake()`, `unstake()`, or triggers the `update` modifier, the contract calculates how much time has passed since the last update.
   - It then mints `minted = timeElapsed * ratePerSecond` tokens.
   - `rewardPerShare` is updated as `rewardPerShare += (minted * 1e18) / totalStaked`.
   - Each user’s pending rewards are `staked[msg.sender] * rewardPerShare / 1e18 - debt[msg.sender]`.
   - Those rewards are minted directly to the user, and `debt[msg.sender]` is updated accordingly.

3. **Staking Flow**

   - User calls `stake(amount)` to deposit tokens in the contract.
   - The user’s `staked[msg.sender]` increases by `amount`.
   - The user’s `debt[msg.sender]` is set to the new checkpoint so that future reward calculations are accurate.

4. **Unstaking Flow**
   - User calls `unstake()`, which currently withdraws **all** staked tokens.
   - The contract transfers staked tokens back to the user, and updates their `debt` to reflect a zero stake.
