pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/payment/PaymentSplitter.sol";

contract FFPaymentSplit is PaymentSplitter {

    using Roles for Roles.Role;
    Roles.Role private _admin;
    Roles.Role private _orgs;

    constructor(address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares)
        public payable {
        _admin.add(msg.sender);
        for (uint256 i = 0; i < _payees.length; ++i) {
            _orgs.add(_payees[i]);
        }
    }
}