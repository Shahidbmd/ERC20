// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
 import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 import "@openzeppelin/contracts/access/Ownable.sol";

contract NativeICO is Ownable {
    uint256 private immutable publicPrice;
    uint256 private immutable privatePrice;
    IERC20 UniqueToken;
    
    //Events
    event paymentMethods (uint256 indexed _paymentId, IERC20 indexed _paymentTokens);
    //whitelist mapping
    mapping(address => bool) private whiteListedAddress;
    
    //mapping id to token Addresses
    mapping(uint => IERC20) public paymentTokens;

    //ensure to use payment Id once
    mapping(uint => bool) private payMethodAdded;

    constructor(uint256 _publicPrice,uint256 _privatePrice, IERC20 _UniqueToken) {
        require(_publicPrice > 0 && _privatePrice > 0, "Invalid prices");
        publicPrice = _publicPrice;
        privatePrice= _privatePrice;
        UniqueToken = _UniqueToken;
    }

    //set paymement methods
     function setPaymentTokens(uint256 _paymentId,IERC20 _paymentToken) external onlyOwner{
        require(!payMethodAdded[_paymentId], "PaymentId already added");
        require(address(_paymentToken) != address(0),"invalid TokenAddress");
        require(_paymentId >0 && _paymentId <5, "Invalid Payment Id");
        paymentTokens[_paymentId] = _paymentToken;
        payMethodAdded[_paymentId] = true;
        emit paymentMethods(_paymentId, _paymentToken);
    }

    function addToWhiteList(address _account) external onlyOwner {
        whiteListedAddress[_account] = true;
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
    
    function publicOffer(uint _buyTokens,uint256 _paymentId) external payable {
        require(_buyTokens > 0, "Invalid token amount");
        IERC20 wallet = paymentTokens[_paymentId];
        uint totalPrice = publicPrice * _buyTokens;
        require(msg.value == totalPrice, "Invalid buying Fee");
        wallet.transferFrom(msg.sender,address(this),totalPrice);
        UniqueToken.transferFrom(owner(),msg.sender,_buyTokens);
    }

    function privateOffer(uint _buyTokens,uint256 _paymentId) external payable {
        require(_buyTokens > 0, "Invalid token amount");
        require(isWhiteListed(msg.sender),"Only for whitelisted");
        IERC20 wallet = paymentTokens[_paymentId];
        uint totalPrice = privatePrice * _buyTokens;
        require(msg.value == totalPrice, "Invalid buying Fee");
        wallet.transferFrom(msg.sender,address(this),totalPrice);
        UniqueToken.transferFrom(owner(),msg.sender,_buyTokens);
    }


    function withdrawFunds() external onlyOwner {
        require(address(this).balance >0,"unsufficient Funds");
        (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "Transaction Failed");
    }
}