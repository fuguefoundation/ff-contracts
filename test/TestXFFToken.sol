pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/XFFToken.sol";

contract TestXFFToken {

  function setNameAndSymbolUsingDeployedContract() public {
    XFFToken xff = XFFToken(DeployedAddresses.XFFToken());

    string memory name = "Fugue Foundation";

    Assert.equal(xff.name(), name, "Error with XFFToken name");
  }

}
