pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/payment/PaymentSplitter.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";
import "./XFFToken.sol";

contract FFPaymentSplit is PaymentSplitter {

    event OrgGroupAdded(uint id);
    event DonationReceived(uint donationId, address indexed donor, uint amount);

    // OZ counter control
    using Counters for Counters.Counter;
    Counters.Counter private _donationIds;

    // OZ access control
    using Roles for Roles.Role;
    Roles.Role private _admin;
    Roles.Role private _orgs;

    // Mapping between addresses and how much money they have withdrawn.
    mapping(address => uint) public amountsWithdrew;

    // The total amount of funds which has been deposited into the contract.
    uint public totalInput;

    // Address of NFT contract and tokenURI link
    address private nftContractAddr;
    string private _tokenURI = "https://fuguefoundation.org/token";

    // Arrays of structs for each donation given and org added
    Org[] private orgs;
    Donation[] private donations;

    struct Org {
        address addr;
        uint share;
        uint id;
    }

    struct OrgGroup {
        uint id;
        Org[] orgs;
    }

    struct Donation {
        uint id;
        uint amount;
        address from;
        OrgGroup group;
    }

    constructor(address[] memory _payees, uint256[] memory _shares)
    PaymentSplitter(_payees, _shares)
        public payable {
        _admin.add(msg.sender);
        for (uint256 i = 0; i < _payees.length; ++i) {
            _orgs.add(_payees[i]);
        }
    }

    /**
     * @dev Set NFT contract address
     * @param addr The address of the NFT contract.
     */

    function setNFTContractAddr(address addr) public {
        require(_admin.has(msg.sender), "DOES_NOT_HAVE_ADMIN_ROLE");
        require(addr != address(0), "FFPaymentSplitter: NFT contract is a zero address");
        nftContractAddr = addr;
    }

    /**
     * @dev Allow admin role to add group
     */

    // function addGroup() public {
    // }

    /**
     * @dev Donate and split funds among payees, msg.sender receives NFT
     */

    function donate() public payable {
        require(nftContractAddr != address(0), "FFPaymentSplitter: NFT contract is a zero address");
        _donationIds.increment();
        uint256 newDonationId = _donationIds.current();

        XFFToken t = XFFToken(nftContractAddr);
        t.grantToken(msg.sender, _tokenURI);
        emit DonationReceived(newDonationId, msg.sender, msg.value);
    }

    function terminate() public {
        require(_admin.has(msg.sender), "DOES_NOT_HAVE_ADMIN_ROLE");
        selfdestruct(address(msg.sender));
    }

}