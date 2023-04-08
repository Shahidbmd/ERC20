// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
 import "./IERC20.sol";
 import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
 import "@openzeppelin/contracts/access/Ownable.sol";

contract ICO is Ownable, ReentrancyGuard {
    //token for ICO
    IERC20 buildMydapp;

    //token for Payment
    IERC20 paymentToken;
    //Events
    event paymentDetail (uint8 indexed _paymentId, IERC20 indexed _paymentTokens);
    event purchasedTokens ( address indexed owner, uint256 _totalPrice, uint256 _totalTokens);

    // //mapping id to token Addresses
    mapping(uint8 => IERC20) private  paymentTokens;

    uint256 public constant buyTokenRate = 5 *10**18;

    constructor(IERC20 _buildMydapp) {
        isValidToken(_buildMydapp);
        buildMydapp= IERC20(_buildMydapp);
    }

    //set paymement methods
     function setPaymentDetails(uint8 _paymentId,IERC20 _paymentToken) external onlyOwner{
        isValidToken(_paymentToken);
        isValidPayId(_paymentId);
        paymentTokens[_paymentId] = _paymentToken;
        emit paymentDetail (_paymentId, _paymentToken);
    }
    

    // buy buildMyDapp token 1 token pay to get 5 tokens
    function buyTokens(uint256 _amountToPay,uint8 _paymentId) external {
        isValidAmount(_amountToPay);
        isValidPayId(_paymentId);
        IERC20 paymentTAddress = paymentTokenAddress(_paymentId);
        uint256 tokensToTransfer = (_amountToPay * buyTokenRate) /paymentTAddress.decimals();
        isValidAmount(tokensToTransfer);
        transferPayment(_paymentId,msg.sender, address(this), _amountToPay);
        transferTokens(msg.sender,tokensToTransfer);
        emit purchasedTokens(msg.sender, _amountToPay , tokensToTransfer);

    }

    function isValidAmount(uint256 _amount) private pure {
        require(_amount > 0, "Invalid token amount");
    }

    function isValidPayId(uint8 _paymentId) private pure {
        require(_paymentId >0 && _paymentId <5, "Invalid Payment Id");
    }

    function isValidToken(IERC20 _tokenAddress) private pure {
        require(address(_tokenAddress) != address(0), "Invalid Token Address");
    }

    function paymentTokenAddress(uint8 _paymentId) public view returns(IERC20){
        return paymentTokens[_paymentId];
    }
    
    function transferPayment(uint8 _paymentId, address from , address to, uint256 _totalPrice) private nonReentrant {
        IERC20 wallet = paymentTokens[_paymentId];
        wallet.transferFrom(from,to,_totalPrice);
    }
    function transferTokens(address to,uint256 _buyTokens) private nonReentrant {
        buildMydapp.transferFrom(owner(),to, _buyTokens);
    }

    
}