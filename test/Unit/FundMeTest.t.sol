// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 public constant FUNDING_PRICE = 5e18;
    uint256 public constant STARTING_BALANCE = 100e18;
    uint256 public constant GAS_PRICE = 1;
    modifier funded(){
        vm.prank(USER);
        fundme.fund{value: FUNDING_PRICE}();
        _;
    }

    function setUp() external {
        //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumIsFive() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerMsgSender() public view {
        console.log(fundme.getOwner());
        console.log(address(this));
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }
    function testFundFailedWithoutEnoughEth() public{


        vm.expectRevert();
        fundme.fund();

    }

    function testFundSuccessWithEnoughEth() public{
        vm.prank(USER);
        fundme.fund{value: FUNDING_PRICE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, FUNDING_PRICE);
    }
    function testAddsFunderToArray() public funded{
        
        address  funder = fundme.getFunder(0);
        assertEq(funder, USER);
        
    }
    function testOnlyOwnerCanWithdraw() public funded{
        

        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }
    function testWithDrawWithSingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalanece = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        //ACT
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 gasEnd = gasleft();

        uint256 gasUsed =( gasStart - gasEnd)*tx.gasprice;
        console.log(gasUsed);
        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalanece, endingOwnerBalance);



    }
    //Arrange
    //Act
    //Assert
    function testWithMultipleFunders() public funded(){
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++){
            hoax(address(i), STARTING_BALANCE);
            fundme.fund{value: FUNDING_PRICE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        assertEq(address(fundme).balance , 0);

        assertEq(startingFundMeBalance+startingOwnerBalance , fundme.getOwner().balance );

    }

     function testWithMultipleFundersCheaper() public funded(){
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++){
            hoax(address(i), STARTING_BALANCE);
            fundme.fund{value: FUNDING_PRICE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.cheaperWithdraw();
        vm.stopPrank();

        assertEq(address(fundme).balance , 0);

        assertEq(startingFundMeBalance+startingOwnerBalance , fundme.getOwner().balance );

    }
}
