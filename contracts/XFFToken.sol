pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

contract XFFToken is ERC721Full {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using Roles for Roles.Role;
    Roles.Role private _admin;
    Roles.Role private _orgs;

    constructor(string memory _name, string memory _symbol) ERC721Full(_name, _symbol) public {
        _admin.add(msg.sender);
    }

    /**
     * @dev Grants token
     * @param recipient address that receives token
     * @param tokenURI resolves to JSON document
     * @return newItemId
     */
    function grantToken(address recipient, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}