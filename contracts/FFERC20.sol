pragma solidity ^0.6.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FFERC20 is ERC20 {
    constructor(uint256 initialSupply, string memory _name, string memory _symbol)
    ERC20(_name, _symbol) public {
        _mint(msg.sender, initialSupply);
    }
}