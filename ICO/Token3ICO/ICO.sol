// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
 import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 import "@openzeppelin/contracts/access/Ownable.sol";

contract ICO is Ownable {
    uint256 private immutable publicPrice;
    uint256 private immutable privatePrice;
    //token for ICO
    IERC20 buildMydapp;
    //Events
    event paymentMethods (uint256 indexed _paymentId, IERC20 indexed _paymentTokens);
    event whiteListStatus (address indexed _account, bool _status);
    event purchasedTokens ( address indexed owner, uint256 _totalPrice, uint256 _totalTokens);
    //whitelist mapping
    mapping(address => bool) private whiteListedAddress;
    
    //mapping id to token Addresses
    mapping(uint8 => IERC20) public paymentTokens;


    constructor(uint256 _publicPrice,uint256 _privatePrice, IERC20 _buildMydapp) {
        require(_publicPrice > 0 && _privatePrice > 0, "Invalid prices");
        isValidToken(_buildMydapp);
        publicPrice = _publicPrice;
        privatePrice= _privatePrice;
        buildMydapp= _buildMydapp;
    }

    //set paymement methods
     function setPaymentTokens(uint8 _paymentId,IERC20 _paymentToken) external onlyOwner{
        isValidToken(_paymentToken);
        isVaalidPayId(_paymentId);
        paymentTokens[_paymentId] = _paymentToken;
        emit paymentMethods(_paymentId, _paymentToken);
    }
    //add to whitelist
    function addToWhiteList(address _account) external onlyOwner {
        whiteListedAddress[_account] = true;
        emit whiteListStatus(_account,isWhiteListed(_account));
    }
    
    function isWhiteListed(address _account) public view returns(bool){
        return whiteListedAddress[_account];
    }

    function getPublicPrice() external view returns(uint256){
        return publicPrice;
    }

    function getPrivatePrice() external view returns(uint256){
        return privatePrice;
    }
    // buy buildMyDapp token publically
    function publicOffer(uint256 _amountToPay,uint8 _paymentId) external {
        isValidAmount(_amountToPay);
        isVaalidPayId(_paymentId);
        uint256 tokenAmount = _amountToPay / publicPrice;
        uint totalPrice = publicPrice * tokenAmount;
        transferPayment(_paymentId, msg.sender, address(this), totalPrice);
        transferTokens(msg.sender,tokenAmount * 10 ** 18);
        emit purchasedTokens(msg.sender, totalPrice , tokenAmount);
    }
    // buy buildMyDapp token privately
    function privateOffer(uint256 _amountToPay,uint8 _paymentId) external {
        require(isWhiteListed(msg.sender),"Only for whitelisted");
        isValidAmount(_amountToPay);
        isVaalidPayId(_paymentId);
        uint256 tokenAmount = _amountToPay / privatePrice;
        uint totalPrice = privatePrice * tokenAmount;
        transferPayment(_paymentId, msg.sender, address(this), totalPrice);
        transferTokens(msg.sender,tokenAmount * 10 ** 18);
        emit purchasedTokens(msg.sender, totalPrice , tokenAmount);

    }

    function isValidAmount(uint256 _buyTokens) private pure {
        require(_buyTokens > 0, "Invalid token amount");
    }

    function isVaalidPayId(uint256 _paymentId) private pure {
        require(_paymentId >0 && _paymentId <5, "Invalid Payment Id");
    }

    function isValidToken(IERC20 _tokenAddress) private pure {
        require(address(_tokenAddress) != address(0), "Invalid Token Address");
    }
    
    function transferPayment(uint8 _paymentId, address from , address to, uint256 _totalPrice) private {
        IERC20 wallet = paymentTokens[_paymentId];
        wallet.transferFrom(from,to,_totalPrice);
    }
    function transferTokens(address to,uint256 _buyTokens) private {
        buildMydapp.transferFrom(owner(),to, _buyTokens);
    }

    
}