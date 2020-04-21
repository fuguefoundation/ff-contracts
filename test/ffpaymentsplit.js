const FFKudos = artifacts.require("FFKudos");
const FFPaymentSplit = artifacts.require("FFPaymentSplit");

contract("FFPaymentSplit", async (accounts) => {
  let contractInstance;
  let kudosInstance;

  beforeEach(async () => {
    contractInstance = await FFPaymentSplit.new([accounts[4], accounts[5], accounts[6]], [3, 2 , 1]);
    kudosInstance = await FFKudos.new("TestFugue", "TF");
    await kudosInstance.mint(kudosInstance.address, 0, 1337, "foo");
    await kudosInstance.setCloneFeePercentage(0);
    await contractInstance.setNFTDetails(kudosInstance.address, 1);
  });

  xit("should be able to receive Ethers", async () => {
    let [,from] = accounts;
    let value = web3.utils.toWei("12", "ether");

    await contractInstance.sendTransaction({ from, value });

    let balance = await web3.eth.getBalance(contractInstance.address);
    assert.equal("12", web3.utils.fromWei(balance));
  });

  it("should distribute funds according to the shares owned", async () => {
    let [,from] = accounts;
    let value = web3.utils.toWei("12", "ether");

    await contractInstance.sendTransaction({ from, value });

    let starting4 = await web3.eth.getBalance(accounts[4]);
    await contractInstance.release(accounts[4]);
    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("6", web3.utils.fromWei((balance4 - starting4).toString()));

    let starting5 = await web3.eth.getBalance(accounts[5]);
    await contractInstance.release(accounts[5]);
    let balance5 = await web3.eth.getBalance(accounts[5]);
    assert.equal("4", web3.utils.fromWei((balance5 - starting5).toString()));

    let starting6 = await web3.eth.getBalance(accounts[6]);
    await contractInstance.release(accounts[6]);
    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("2", web3.utils.fromWei((balance6 - starting6).toString()));
  });
});
