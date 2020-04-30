pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

// Interface to expose NFT clone in FFKudos
contract IFFKudos {
    function clone(address _to, uint256 _tokenId, uint256 _numClonesRequested) public payable;
}

contract FFPaymentSplit {
    using SafeMath for uint256;

    uint constant MAX_EVALUATOR_ID = 5;

    event DonationReceived(uint donationId, address indexed donor, uint amount, bytes evaluator);
    event OrgAdded(address org, uint evaluatorId);
    event OrgRemoved(address org, uint evaluatorId);
    event PaymentDistributed(address to, uint amount, uint evaluatorId);

    // OZ counter control
    using Counters for Counters.Counter;
    Counters.Counter private _donationIds;

    // OZ access control
    using Roles for Roles.Role;
    Roles.Role private _admin;

    // Mapping between addresses and how much money they have withdrawn.
    mapping(address => uint) public amountsWithdrew;
    mapping(uint => PaymentDetails) public paymentLedger;
    mapping(address => uint) public evaluatorLookup;

    // Address of NFT contract and tokenURI link
    IFFKudos private _ffKudosInterface;
    uint256 public tokenId;
    address public tokenAddress;

    // Arrays of structs for each donation given and org added
    Org[] private orgs;
    Donation[] private donations;
    uint private totalDonated;

    struct PaymentDetails {
        uint totalDistributed;
        uint totalDonated;
        address payable[] payees;
    }

    struct Org {
        address addr;
        uint id;
        uint evaluatorId;
    }

    struct Donation {
        uint id;
        uint evaluatorId;
        uint amount;
        address from;
    }

    constructor(address payable[] memory _payees, uint[] memory _evaluatorIds)
        public payable
    {
        require(_evaluatorIds.length == _payees.length, "Array size of _evaluatorIds does not match payees");

        _admin.add(msg.sender);

        for (uint i = 0; i < _evaluatorIds.length; i++) {
            uint evaluatorId = _evaluatorIds[i];
            require(evaluatorId > 0 && evaluatorId <= MAX_EVALUATOR_ID, "Invalid evaluatorId supplied");

            evaluatorLookup[_payees[i]] = evaluatorId;
            paymentLedger[evaluatorId].payees.push(_payees[i]);
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
     * @dev Allow admin role to add an organization.
     * @param payee Address of the organization
     * @param evaluatorId The evaluator ID for the payee organization
     */

    function addOrg(address payable payee, uint evaluatorId) public onlyAdmin {
        require(evaluatorId > 0 && evaluatorId <= MAX_EVALUATOR_ID, "Invalid evaluatorId supplied");
        evaluatorLookup[payee] = evaluatorId;
        paymentLedger[evaluatorId].payees.push(payee);
        emit OrgAdded(payee, evaluatorId);
    }

    /**
     * @dev Allow admin role to remove an organization.
     * @param payee The address of the organization to remove
     */

    function removeOrg(address payee) public onlyAdmin {
        uint evaluatorId = evaluatorLookup[payee];

        if (evaluatorId != 0) {
            address payable[] storage payees = paymentLedger[evaluatorId].payees;

            for (uint i = 0; i < payees.length; i++) {
                if (payees[i] == payee) {
                    delete payees[i];
                    payees.length--;
                    break;
                }
            }

            delete evaluatorLookup[payee];
            emit OrgRemoved(payee, evaluatorId);
        }
    }

    /**
     * @dev Donation funds are split among payees, msg.sender receives NFT clone
     */

    function() external payable {
        // Check is required here to prevent reentrancy from the Kudos contract
        if (msg.sender != address(_ffKudosInterface)) {
            require(address(_ffKudosInterface) != address(0), "FFPaymentSplitter: NFT contract is not set");

            uint evaluatorId = uint(uint8(msg.data[0]));
            require(evaluatorId > 0 && evaluatorId <= MAX_EVALUATOR_ID, "Invalid evaluatorId supplied");
            uint256 newDonationId = _donationIds.current();
            _donationIds.increment();

            _ffKudosInterface.clone(msg.sender, tokenId, 1);
            totalDonated += msg.value;
            paymentLedger[evaluatorId].totalDonated += msg.value;

            emit DonationReceived(newDonationId, msg.sender, msg.value, msg.data);
            _release(evaluatorId);
        }
    }

    function release(address payable account) public {
        uint evaluatorId = evaluatorLookup[account];
        _release(evaluatorId);
    }

    function _release(uint evaluatorId) internal {
        PaymentDetails storage details = paymentLedger[evaluatorId];
        uint pendingPayment = details.totalDonated.sub(details.totalDistributed);

        if (pendingPayment > 0) {
            uint paymentShare = pendingPayment.div(details.payees.length);

            for (uint256 i = 0; i < details.payees.length; i++) {
                address payable payee = details.payees[i];

                payee.transfer(paymentShare);
                amountsWithdrew[payee] += paymentShare;
                details.totalDistributed += paymentShare;

                emit PaymentDistributed(payee, paymentShare, evaluatorId);
            }
        }
    }

    function terminate() public onlyAdmin {
        selfdestruct(address(msg.sender));
    }

}
