const FFERC20 = artifacts.require("FFERC20");
const FFDonation = artifacts.require("FFDonation");
const txHash = "0x5c09db7c7c9024c62730603aa4277d6638851cd9c37e5612f2adf310ee9bb2ce";

contract("FFERC20", async (accounts) => {
  let ffERC20Instance;

  beforeEach(async () => {
    ffERC20Instance = await FFERC20.new(200, "FugueERC20", "XFF");
  });

  it("should set totalSupply, name, symbol correctly", async () => {

    const totalSupply = await ffERC20Instance.totalSupply.call();
    const name = await ffERC20Instance.name.call();
    const symbol = await ffERC20Instance.symbol.call();

    assert.equal(totalSupply, 200);
    assert.equal(name, "FugueERC20");
    assert.equal(symbol, "XFF");
  });

  it("should send ERC20 from user to FFDonation contract", async () => {
    let value = web3.utils.toWei("2", "ether");

    ffDonationInstance = await FFDonation.new([accounts[4], accounts[5], accounts[6]], [1, 2, 1]);
    let balanceBefore, balanceAfter;
    balanceBefore = await ffERC20Instance.balanceOf(ffDonationInstance.address).then(result => {
        return result;
    });
    await ffERC20Instance.transfer(ffDonationInstance.address, 2);
    balanceAfter = await ffERC20Instance.balanceOf(ffDonationInstance.address).then(result => {
        return result;
    });

    assert.isAbove(Number(balanceAfter), Number(balanceBefore));
  });

});
