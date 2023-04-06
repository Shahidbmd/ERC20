// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
 import "./IERC20.sol";
 import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
 import "@openzeppelin/contracts/access/Ownable.sol";

contract ICO is Ownable, ReentrancyGuard {
    //token for ICO
    IERC20 buildMydapp;
    //Events
    event paymentDetail (uint8 indexed _paymentId, IERC20 indexed _paymentTokens, uint256 _pvtConvertRate,uint256 _plcConvertRate);
    event whiteListStatus (address indexed _account, bool _status, address _whose);
    event purchasedTokens ( address indexed owner, uint256 _totalPrice, uint256 _totalTokens);
    //whitelist mapping
    mapping(address => bool) private whiteListedAddress;
    
    //mapping id to token Addresses
    mapping(uint8 => IERC20) private paymentTokens;

    //mapping paymentToken to Conversion Rate;
    mapping(IERC20 => uint256) private privateConversionRate; 
    mapping(IERC20 => uint256) private publicConversionRate; 

    constructor(IERC20 _buildMydapp) {
        isValidToken(_buildMydapp);
        buildMydapp= _buildMydapp;
    }

    //set paymement methods
     function setPaymentDetails(uint8 _paymentId,IERC20 _paymentToken,uint256 _pvtConvertRate,uint256 _plcConvertRate) external onlyOwner{
        isValidAmount(_pvtConvertRate);
        isValidAmount(_plcConvertRate);
        isValidToken(_paymentToken);
        isValidPayId(_paymentId);
        paymentTokens[_paymentId] = _paymentToken;
        privateConversionRate[_paymentToken] = _pvtConvertRate;
        publicConversionRate[_paymentToken] = _plcConvertRate;
        emit paymentDetail(_paymentId, _paymentToken, _pvtConvertRate, _plcConvertRate);
    }
    //add to whitelist
    function addToWhiteList(address _account) external onlyOwner {
        whiteListedAddress[_account] = true;
        emit whiteListStatus(_account,isWhiteListed(_account),msg.sender);
    }

    //remove from whitelist
    function removeFromWhiteList(address _account) external onlyOwner {
        whiteListedAddress[_account] = false;
        emit whiteListStatus(_account,isWhiteListed(_account),msg.sender);
    }
    
    function isWhiteListed(address _account) public view returns(bool){
        return whiteListedAddress[_account];
    }
    
    // public price of Token in given paymentId
    function getPublicPrice(uint8 _paymentId) external view returns(uint256){
        isValidPayId(_paymentId);
        return publicConversionRate[tokenAddress(_paymentId)];
    }
    
    // private price of Token in given paymentId
    function getPrivatePrice(uint8 _paymentId) external view returns(uint256){
        isValidPayId(_paymentId);
        return privateConversionRate[tokenAddress(_paymentId)];
    }
    
    // get payemntToken Address via paymentId
    function getPaymentAddress(uint8 _paymentId) external view returns (address) {
        isValidPayId(_paymentId);
        return address(paymentTokens[_paymentId]);
    }

    // buy buildMyDapp token publically
    function publicOffer(uint256 _amountToPay,uint8 _paymentId) external {
        isValidAmount(_amountToPay);
        isValidPayId(_paymentId);
        uint256 convertRate = publicConversionRate[paymentTokens[_paymentId]];
        uint256 tokenAmount = _amountToPay / convertRate;
        uint totalPrice = convertRate * tokenAmount;
        isValidAmount(totalPrice);
        transferPayment(_paymentId, msg.sender, address(this), totalPrice);
        transferTokens(msg.sender,tokenAmount * 10 ** buildMydapp.decimals());
        emit purchasedTokens(msg.sender, totalPrice , tokenAmount);
    }
    // buy buildMyDapp token privately
    function privateOffer(uint256 _amountToPay,uint8 _paymentId) external {
        require(isWhiteListed(msg.sender),"Only for whitelisted");
        isValidAmount(_amountToPay);
        isValidPayId(_paymentId);
        uint256 convertRate = privateConversionRate[paymentTokens[_paymentId]];
        uint256 tokenAmount = _amountToPay / convertRate;
        uint totalPrice = convertRate * tokenAmount;
        isValidAmount(totalPrice);
        transferPayment(_paymentId, msg.sender, address(this), totalPrice);
        transferTokens(msg.sender,tokenAmount * 10 ** buildMydapp.decimals());
        emit purchasedTokens(msg.sender, totalPrice , tokenAmount);

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

    function tokenAddress(uint8 _paymentId) private view returns(IERC20){
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