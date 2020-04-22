const FFKudos = artifacts.require("FFKudos");
const FFPaymentSplit = artifacts.require("FFPaymentSplit");

contract("FFPaymentSplit", async (accounts) => {
  let ffPaymentInstance;
  let kudosInstance;

  beforeEach(async () => {
    ffPaymentInstance = await FFPaymentSplit.new([accounts[4], accounts[5], accounts[6]], [1, 1 , 1], [1, 2, 3]);
    kudosInstance = await FFKudos.new("TestFugue", "TF");
    await kudosInstance.mint(kudosInstance.address, 0, 1337, "foo");
    await kudosInstance.setCloneFeePercentage(0);
    await ffPaymentInstance.setNFTDetails(kudosInstance.address, 1);
  });

  it("should be able to receive ether", async () => {
    let [,from] = accounts;
    let value = web3.utils.toWei("3", "ether");

    await ffPaymentInstance.sendTransaction({ from, value });

    let balance = await web3.eth.getBalance(ffPaymentInstance.address);
    assert.equal("3", web3.utils.fromWei(balance));
  });

  it("should distribute funds according to the shares owned", async () => {
    let [,from] = accounts;
    let value = web3.utils.toWei("3", "ether");
    let data = web3.utils.toHex(2);

    await ffPaymentInstance.sendTransaction({ from, value, data });

    let starting4 = await web3.eth.getBalance(accounts[4]);
    await ffPaymentInstance.release(accounts[4]);
    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("1", web3.utils.fromWei((balance4 - starting4).toString()));

    let starting5 = await web3.eth.getBalance(accounts[5]);
    await ffPaymentInstance.release(accounts[5]);
    let balance5 = await web3.eth.getBalance(accounts[5]);
    assert.equal("1", web3.utils.fromWei((balance5 - starting5).toString()));

    let starting6 = await web3.eth.getBalance(accounts[6]);
    await ffPaymentInstance.release(accounts[6]);
    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("1", web3.utils.fromWei((balance6 - starting6).toString()));

  });
});
