const FFKudos = artifacts.require("FFKudos");
const FFPaymentSplit = artifacts.require("FFPaymentSplit");

contract("FFPaymentSplit", async (accounts) => {
  let ffPaymentInstance;
  let kudosInstance;

  beforeEach(async () => {
    ffPaymentInstance = await FFPaymentSplit.new([accounts[4], accounts[5], accounts[6]], [1, 2, 1]);
    kudosInstance = await FFKudos.new("TestFugue", "TF");
    await kudosInstance.mint(kudosInstance.address, 0, 1337, "foo");
    await kudosInstance.setCloneFeePercentage(0);
  });

  it("should set NFT details correctly", async () => {
    await ffPaymentInstance.setNFTDetails(kudosInstance.address, 1);

    const tokenId = await ffPaymentInstance.tokenId.call();
    const tokenAddress = await ffPaymentInstance.tokenAddress.call();

    assert.equal(tokenId, 1);
    assert.equal(tokenAddress, kudosInstance.address);
  });

  it("should distribute funds to the correct organizations with the evaluatorId supplied", async () => {
    await ffPaymentInstance.setNFTDetails(kudosInstance.address, 1);

    let [,from] = accounts;
    let value = web3.utils.toWei("4", "ether");
    let data = web3.utils.toHex(1);

    let starting4 = await web3.eth.getBalance(accounts[4]);
    let starting5 = await web3.eth.getBalance(accounts[5]);
    let starting6 = await web3.eth.getBalance(accounts[6]);
    await ffPaymentInstance.sendTransaction({ from, value, data });

    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("2", web3.utils.fromWei((balance4 - starting4).toString()));

    let balance5 = await web3.eth.getBalance(accounts[5]);
    assert.equal("0", web3.utils.fromWei((balance5 - starting5).toString()));

    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("2", web3.utils.fromWei((balance6 - starting6).toString()));
  });

  it("should no longer distribute funds to organizations that have been removed", async () => {
    await ffPaymentInstance.setNFTDetails(kudosInstance.address, 1);

    await ffPaymentInstance.removeOrg(accounts[6]);

    let [,,from] = accounts;
    let value = web3.utils.toWei("3", "ether");
    let data = web3.utils.toHex(1);

    let starting4 = await web3.eth.getBalance(accounts[4]);
    let starting6 = await web3.eth.getBalance(accounts[6]);
    await ffPaymentInstance.sendTransaction({ from, value, data });

    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("3", web3.utils.fromWei((balance4 - starting4).toString()));

    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("0", web3.utils.fromWei((balance6 - starting6).toString()));
  });

  it("should distribute funds to an organization that have been added after a recent removal of another org", async () => {
    await ffPaymentInstance.setNFTDetails(kudosInstance.address, 1);

    await ffPaymentInstance.removeOrg(accounts[6]);
    await ffPaymentInstance.addOrg(accounts[7], 1);

    let [,,from] = accounts;
    let value = web3.utils.toWei("2", "ether");
    let data = web3.utils.toHex(1);

    let starting4 = await web3.eth.getBalance(accounts[4]);
    let starting6 = await web3.eth.getBalance(accounts[6]);
    let starting7 = await web3.eth.getBalance(accounts[7]);
    await ffPaymentInstance.sendTransaction({ from, value, data });

    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("1", web3.utils.fromWei((balance4 - starting4).toString()));

    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("0", web3.utils.fromWei((balance6 - starting6).toString()));

    let balance7 = await web3.eth.getBalance(accounts[7]);
    assert.equal("1", web3.utils.fromWei((balance7 - starting7).toString()));
  });
});
