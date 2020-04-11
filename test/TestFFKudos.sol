pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FFKudos.sol";

contract TestFFKudos {

  function setNameAndSymbolUsingDeployedContract() public {
    FFKudos ffk = FFKudos(DeployedAddresses.FFKudos());

    string memory name = "Fugue Foundation";

    Assert.equal(ffk.name(), name, "Error with FFKudos name");
  }

}
