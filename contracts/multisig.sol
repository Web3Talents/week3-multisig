// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

//import IERC20 interface
    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Multisig {
    error InvalidInput();
    error Forbidden();
    error Unauthorized();
    error NotEnoughTokensOrAllowance();
    error CannotVerifyOwnTx();

    event TransactionInitiated(address tokenCA,address sender, address receiver, uint amount);

    address private admin;
    uint private counter;

    IERC20 private mtokens;

    struct TransactionDetails {
        address token;
        uint amount;
        address sender;
        address approver;
        address receiver;
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

    modifier approvedOnly {
        if(!Owners[msg.sender]) revert Unauthorized();
        _;
            }

    function setAcceptedTokens(address _tokenAddress)  external approvedOnly{
        if(_tokenAddress == address(0)) revert InvalidInput();
        acceptedToken[_tokenAddress] = true;
        mtokens = IERC20(_tokenAddress);
    }

    function depositFunds( uint amount)external{
       // if(!acceptedToken[_tokenAddress]) revert Forbidden();
        if(amount ==0) revert InvalidInput();
        
        if(mtokens.balanceOf(msg.sender)<amount) revert NotEnoughTokensOrAllowance();
        mtokens.transferFrom(msg.sender, address(this), amount);
    }

    function initiateWithdrawal(address _tokenAddress,address to, uint amount) external approvedOnly{
        if(!acceptedToken[_tokenAddress]) revert Forbidden();
        if(amount ==0) revert InvalidInput();
        uint _id = ++counter;
        TransactionDetails storage txInit = transactionDetails[_id];
        txInit.sender = msg.sender;
        txInit.receiver = to;
        txInit.token = _tokenAddress;
        txInit.amount = amount;

        emit TransactionInitiated(_tokenAddress, msg.sender, to, amount);
    }

    function completeWithdrawal(uint _id) external approvedOnly{ 
        if(_id == 0) revert InvalidInput();
        TransactionDetails storage txCompletion = transactionDetails[_id];
   
        address tReceiver = txCompletion.receiver;
        uint amount = txCompletion.amount;
  

        if(msg.sender == txCompletion.sender) revert CannotVerifyOwnTx();
        if(mtokens.balanceOf(address(this)) < amount) revert NotEnoughTokensOrAllowance();
        mtokens.transfer(tReceiver, amount); 

        txCompletion.txComplete = true;
    }

}