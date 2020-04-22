pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Roles.sol";
import "./PaymentSplitter.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

// Interface to expose NFT clone in FFKudos
contract IFFKudos {
    function clone(address _to, uint256 _tokenId, uint256 _numClonesRequested) public payable;
}

contract FFPaymentSplit is PaymentSplitter {

    event DonationReceived(uint donationId, address indexed donor, uint amount, bytes evaluator);

    // OZ counter control
    using Counters for Counters.Counter;
    Counters.Counter private _donationIds;

    // OZ access control
    using Roles for Roles.Role;
    Roles.Role private _admin;

    // Mapping between addresses and how much money they have withdrawn.
    mapping(address => uint) public amountsWithdrew;

    // Address of NFT contract and tokenURI link
    IFFKudos private _ffKudosInterface;
    uint256 public tokenId;
    address public tokenAddress;

    // Arrays of structs for each donation given
    Donation[] private donations;
    uint private totalDonated;

    struct Donation {
        uint id;
        uint evaluatorId;
        uint amount;
        address from;
    }

    constructor(address[] memory _payees, uint256[] memory _shares, uint[] memory _evalId)
        PaymentSplitter(_payees, _shares, _evalId)
        public payable
    {
        _admin.add(msg.sender);
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
     * @dev Donation funds are split among payees, msg.sender receives NFT clone
     */

    function() external payable {
        // Check is required here to prevent reentrancy from the Kudos contract
        if (msg.sender != address(_ffKudosInterface)) {
            require(address(_ffKudosInterface) != address(0), "FFPaymentSplitter: NFT contract is not set");
            _donationIds.increment();
            uint256 newDonationId = _donationIds.current();

            _ffKudosInterface.clone(msg.sender, tokenId, 1);
            totalDonated += msg.value;
            emit DonationReceived(newDonationId, msg.sender, msg.value, msg.data);
        }
    }

    function terminate() public onlyAdmin {
        selfdestruct(address(msg.sender));
    }

}
