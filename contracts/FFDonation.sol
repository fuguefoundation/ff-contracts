pragma solidity ^0.6.0;

import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Interface to expose ERC721 award
interface IFFERC721 {
    function awardNFT(address recipient, string calldata tokenURI) external returns (uint256);
}

// Interface to expose ERC20 transfer and approve functions
interface IFFERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom (address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FFDonation is Context, AccessControl {
    using SafeMath for uint256;
    //IERC20 internal constant DAI_TOKEN_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 internal token;

    uint constant MAX_EVALUATOR_ID = 4;

    event DonationReceived(uint donationId, address indexed donor, uint amount, uint evaluator);
    event OrgAdded(address org, uint evaluatorId);
    event OrgRemoved(address org, uint evaluatorId);
    event PaymentDistributed(address to, uint amount, uint evaluatorId);

    // OZ counter control
    using Counters for Counters.Counter;
    Counters.Counter private _donationIds;

    // OZ access control
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Mapping between addresses and how much money they have withdrawn.
    mapping(address => uint) public amountsWithdrew;
    mapping(uint => PaymentDetails) public paymentLedger;
    mapping(address => uint) public evaluatorLookup;

    // Variables that may change for NFT and donations
    IFFERC721 private _ffERC721Interface;
    address public nftAddress;
    uint256 public defaultEvalId = 1;
    uint256 public minimumNFTDonation = 100000000000000000; //.1 ETH

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

        _setupRole(ADMIN_ROLE, _msgSender());

        for (uint i = 0; i < _evaluatorIds.length; i++) {
            uint evaluatorId = _evaluatorIds[i];
            require(evaluatorId > 0 && evaluatorId <= MAX_EVALUATOR_ID, "Invalid evaluatorId supplied");

            evaluatorLookup[_payees[i]] = evaluatorId;
            paymentLedger[evaluatorId].payees.push(_payees[i]);
        }
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, _msgSender()), "DOES_NOT_HAVE_ADMIN_ROLE");
        _;
    }

    /**
     * @dev Set NFT contract address
     * @param addr The address of the NFT contract.
     */

    function setDonationDetails(address payable addr, uint256 eid, uint256 amount) public onlyAdmin {
        require(addr != address(0), "FFPaymentSplitter: NFT contract is a zero address");
        //_ffKudosInterface = IFFKudos(addr);
        _ffERC721Interface = IFFERC721(addr);
        token = IERC20(addr);
        nftAddress = addr;
        //tokenId = tid;
        defaultEvalId = eid;
        minimumNFTDonation = amount;
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
                    payees.pop();
                    break;
                }
            }

            delete evaluatorLookup[payee];
            emit OrgRemoved(payee, evaluatorId);
        }
    }

    /**
     * @dev Fallback function - donation funds are split among payees, _msgSender() receives NFT clone
     */
    fallback() external payable {
        bytes memory data = _msgData();
        uint evaluatorId;
        if (data.length == 0 ) {
            evaluatorId = defaultEvalId;
        } else {
            evaluatorId = uint(uint8(data[0]));
        }

        require(evaluatorId > 0 && evaluatorId <= MAX_EVALUATOR_ID, "Invalid evaluatorId supplied");
        uint256 newDonationId = _donationIds.current();
        _donationIds.increment();

        if(msg.value >= minimumNFTDonation) {
            //_ffKudosInterface.clone(_msgSender(), tokenId, 1);
            _ffERC721Interface.awardNFT(_msgSender(), "fuguefoundation.org");
        }

        totalDonated += msg.value;
        paymentLedger[evaluatorId].totalDonated += msg.value;

        emit DonationReceived(newDonationId, _msgSender(), msg.value, evaluatorId);
        _release(evaluatorId);
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

    /**
     * @dev Transfer donated ERC20 tokens to designated payees as determined by evalId
     * @param ERC20addr The address of the ERC20 token contract to transfer from
     * @param evalId Evaluator ID for whom to split the donation
     * @param amount Amount of donation
     * @param donor Donor address to receive ERC721
     */

    function transferERC20(address ERC20addr, uint256 evalId, uint256 amount, address donor) public onlyAdmin {
        IFFERC20 _ffERC20Instance = IFFERC20(ERC20addr);
        PaymentDetails storage details = paymentLedger[evalId];
        uint paymentShare = amount.div(details.payees.length);
        for (uint256 i = 0; i < details.payees.length; i++) {
            address payable payee = details.payees[i];
            _ffERC20Instance.transfer(payee, paymentShare);
            emit PaymentDistributed(payee, paymentShare, evalId);
        }
        if (donor != address(0)) {
            _ffERC721Interface.awardNFT(donor, "fuguefoundation.org");
        }
    }

    /**
     * @dev Donate ERC20 tokens to nonprofits associated with `evalId` by `approve` smart contract to `transferFrom`
     * @param ERC20addr The address of the ERC20 token contract to call `approve` and `transferFrom`
     * @param evalId Evaluator ID for whom to split the donation
     * @param amount Amount of donation
     */

    function donateERC20(address ERC20addr, uint256 evalId, uint256 amount) public {
        require(amount > 0, "Amount to donate may not be 0");
        IERC20 _ffERC20Instance = IERC20(ERC20addr);
        //require(_ffERC20Instance.approve(address(this), amount), "Approval to addr failed");
        uint256 allowance = _ffERC20Instance.allowance(_msgSender(), address(this));
        require(allowance >= amount, "Check the token allowance");

        PaymentDetails storage details = paymentLedger[evalId];
        uint paymentShare = amount.div(details.payees.length);

        for (uint256 i = 0; i < details.payees.length; i++) {
            address payable payee = details.payees[i];
            _ffERC20Instance.transferFrom(_msgSender(), payee, paymentShare);
            emit PaymentDistributed(payee, paymentShare, evalId);
        }
        if (_msgSender() != address(0)) {
            _ffERC721Interface.awardNFT(_msgSender(), "fuguefoundation.org");
        }
    }

    function terminate() public onlyAdmin {
        selfdestruct(_msgSender());
    }

}
