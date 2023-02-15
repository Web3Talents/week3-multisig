// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

//import IERC20 interface
import "@openzeppelin/contracts/tokens/ERC20/IERC20.sol";

contract Multisig {
    error InvalidInput();
    error Forbidden();


    address private admin;
    uint private counter;
    struct TransactionDetails {
        address token;
        uint amount;
        address sender;
        address approver;
        bool txComplete;
    }


    mapping (uint => TransactionDetails) public transactionDetails;
    mapping (address => bool) public acceptedToken;
    mapping (address => bool) private Owners;
   
    constructor(address _secondOwner) {
        admin = msg.sender;
        counter =0;
        Owners[msg.sender] = true;
        Owners[_secondOwner] =true;
    }



    function setAcceptedTokens(address _tokenAddress)  external {
        if(_tokenAddress == address(0)) revert InvalidInput();
        acceptedToken[_tokenAddress] = true;
    }
    function depositFunds(address _tokenAddress, uint amount)external{
        if(!acceptedToken[_tokenAddress]) revert Forbidden();
        if(amount ==0) revert InvalidInput();
        IERC20 mtokens = IERC20(_tokenAddress);
        mtokens.transferFrom(msg.sender, address(this), amount);
    }

    function initiateWithdrawal(address _tokenAddress, uint amount) external{
        if(!acceptedToken[_tokenAddress]) revert Forbidden();
        if(amount ==0) revert InvalidInput();
        uint _id = ++counter;
        TransactionDetails storage txInit = transactionDetails[_id];
        txInit.sender = msg.sender;
        txInit.token = _tokenAddress;
        txInit.amount = amount;
    }

    function completeWithdrawal(uint _id) external{
        
    }

}