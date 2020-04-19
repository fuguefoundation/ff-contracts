pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/payment/PaymentSplitter.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

// Interface to expose NFT clone in FFKudos
contract IFFKudos {
    function clone(address _to, uint256 _tokenId, uint256 _numClonesRequested) external view;
    function() external payable { }
}

contract FFPaymentSplit is PaymentSplitter {

    event DonationReceived(uint donationId, address indexed donor, uint amount, uint evaluator);

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
    IFFKudos private _ffKudosInterface;
    uint256 public tokenId;
    address public tokenAddress;

    // Arrays of structs for each donation given and evaluator added
    Evaluator[] private evaluators;
    Donation[] private donations;

    struct Org {
        address addr;
        string name;
        uint id;
    }

    struct Evaluator {
        uint id;
        string name;
        Org[] orgs;
    }

    struct Donation {
        uint id;
        uint amount;
        address from;
        Evaluator evaluator;
    }

    constructor(address[] memory _payees, uint256[] memory _shares)
    PaymentSplitter(_payees, _shares)
        public payable {
        _admin.add(msg.sender);
        for (uint256 i = 0; i < _payees.length; ++i) {
            _orgs.add(_payees[i]);
        }
    }

    modifier onlyAdmin() {
        require(_admin.has(msg.sender), "DOES_NOT_HAVE_ADMIN_ROLE");
        _;
    }

    /**
     * @dev Set NFT contract address
     * @param addr The address of the NFT contract.
     */

    function setNFTDetails(address payable addr, uint256 id) public onlyAdmin {
        require(addr != address(0), "FFPaymentSplitter: NFT contract is a zero address");
        _ffKudosInterface = IFFKudos(addr);
        tokenAddress = addr;
        tokenId = id;
    }

    /**
     * @dev Allow admin role to add evaluator
     */

    // function addEvaluator() public {
    // }

    /**
     * @dev Allow admin role to add orgs. Orgs are assigned to an Evaluator.
     */

    // function addOrgs() public {
    // }

    /**
     * @dev Donation funds are split among payees, msg.sender receives NFT clone
     */

    function() external payable {
        require(address(_ffKudosInterface) != address(0), "FFPaymentSplitter: NFT contract is not set");
        _donationIds.increment();
        uint256 newDonationId = _donationIds.current();

        //_ffKudosInterface.clone(msg.sender, tokenId, 0);
        totalInput += msg.value;
        emit DonationReceived(newDonationId, msg.sender, msg.value, msg.data);
    }

    function terminate() public onlyAdmin {
        selfdestruct(address(msg.sender));
    }

}
