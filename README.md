## Slippage Loss demonstration 
A POC do demonstrate sandwich (frontruning + backrunning ) attack on swap transaction without slippage protection.

Smaller pools are easy to manipulate.
New pools most times have smaller liquidity.
This opens opportunity for so much profit than the one demonstrated in this POC.

## POC location
test/UniswapSlippageTest.sol.

## How to run test?

```
forge test --fork-url YOUR_MAINNET_NODE_URL -vvv
```
- replace the YOUR_MAINNET_NODE_URL above with your node url. You can get one from alchemy.

## Result
```
Running 1 test for test/UniswapSlippageTest.t.sol:UniswapSlippageTest
[PASS] test_SlippageBandit() (gas: 356865)
Logs:
  Alice Before profit: 200000
  Alice During profit: 0
  Alice After profit: 204854
  Alice has just made a Big Profit of  4854 DAI from this testContract's lack of slippage protection
  Yippeee 4854

```