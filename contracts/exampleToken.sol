// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract myCoin is ERC20 {

constructor()ERC20("Example Token", "EXE"){
    _mint(msg.sender, 1000000*10**18);
}


}