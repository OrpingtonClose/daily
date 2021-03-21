pragma solidity ^0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0-solc-0.7/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    constructor () ERC20("DUPA", "DP") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
}

//https://forum.openzeppelin.com/t/deploy-a-simple-erc20-token-in-remix/1203
//https://etherscan.io/address/0x46a9e8446f79ac106ac69877c301b40c1fd4af7b
