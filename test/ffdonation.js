const FFERC20 = artifacts.require("FFERC20");
const FFERC721 = artifacts.require("FFERC721");
const FFDonation = artifacts.require("FFDonation");
const nftDonationAmount = web3.utils.toWei((.1).toString());
const nullAddr = "0x0000000000000000000000000000000000000000";

contract("FFDonation", async (accounts) => {
  let ffDonationInstance;
  let ffERC721Instance;

  beforeEach(async () => {
    ffDonationInstance = await FFDonation.new([accounts[4], accounts[5], accounts[6]], [1, 2, 1]);
    ffERC721Instance = await FFERC721.new("TestFugue", "TF");
  });

  it("should set Donation details correctly", async () => {
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 2, nftDonationAmount);

    const nftAddress = await ffDonationInstance.nftAddress.call();
    const evalId = await ffDonationInstance.defaultEvalId.call();
    const donationAmount = await ffDonationInstance.minimumNFTDonation.call();

    assert.equal(nftAddress, ffERC721Instance.address);
    assert.equal(evalId, 2);
    assert.equal(donationAmount, nftDonationAmount);
  });

  it("should distribute funds to the correct organizations with the evaluatorId supplied", async () => {
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 1, nftDonationAmount);

    let [,from] = accounts;
    let value = web3.utils.toWei("2", "ether");
    let data = web3.utils.toHex(1);

    let starting4 = await web3.eth.getBalance(accounts[4]);
    let starting5 = await web3.eth.getBalance(accounts[5]);
    let starting6 = await web3.eth.getBalance(accounts[6]);
    await ffDonationInstance.sendTransaction({ from, value, data });
 
    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("1", web3.utils.fromWei((balance4 - starting4).toString()));

    let balance5 = await web3.eth.getBalance(accounts[5]);
    assert.equal("0", web3.utils.fromWei((balance5 - starting5).toString()));

    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("1", web3.utils.fromWei((balance6 - starting6).toString()));

  });

  it("should payout to defaultEvalId if msg.data is not given", async () => {
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 1, nftDonationAmount);

    let [,from] = accounts;
    let value = web3.utils.toWei("2", "ether");

    let starting4 = await web3.eth.getBalance(accounts[4]);
    let starting5 = await web3.eth.getBalance(accounts[5]);
    let starting6 = await web3.eth.getBalance(accounts[6]);
    await ffDonationInstance.sendTransaction({ from, value });

    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("1", web3.utils.fromWei((balance4 - starting4).toString()));

    let balance5 = await web3.eth.getBalance(accounts[5]);
    assert.equal("0", web3.utils.fromWei((balance5 - starting5).toString()));

    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("1", web3.utils.fromWei((balance6 - starting6).toString()));

  });

  it("should no longer distribute funds to organizations that have been removed", async () => {
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 1, nftDonationAmount);

    await ffDonationInstance.removeOrg(accounts[6]);

    let [,,from] = accounts;
    let value = web3.utils.toWei("2", "ether");
    let data = web3.utils.toHex(1);

    let starting4 = await web3.eth.getBalance(accounts[4]);
    let starting6 = await web3.eth.getBalance(accounts[6]);
    await ffDonationInstance.sendTransaction({ from, value, data });

    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("2", web3.utils.fromWei((balance4 - starting4).toString()));

    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("0", web3.utils.fromWei((balance6 - starting6).toString()));
  });

  it("should distribute funds to an organization that have been added after a recent removal of another org", async () => {
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 1, nftDonationAmount);

    await ffDonationInstance.removeOrg(accounts[6]);
    await ffDonationInstance.addOrg(accounts[7], 1);

    let [,,from] = accounts;
    let value = web3.utils.toWei("2", "ether");
    let data = web3.utils.toHex(1);

    let starting4 = await web3.eth.getBalance(accounts[4]);
    let starting6 = await web3.eth.getBalance(accounts[6]);
    let starting7 = await web3.eth.getBalance(accounts[7]);
    await ffDonationInstance.sendTransaction({ from, value, data });

    let balance4 = await web3.eth.getBalance(accounts[4]);
    assert.equal("1", web3.utils.fromWei((balance4 - starting4).toString()));

    let balance6 = await web3.eth.getBalance(accounts[6]);
    assert.equal("0", web3.utils.fromWei((balance6 - starting6).toString()));

    let balance7 = await web3.eth.getBalance(accounts[7]);
    assert.equal("1", web3.utils.fromWei((balance7 - starting7).toString()));
  });

  it("should only mint an NFT for donations >= minimumNFTDonation", async () => {
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 1, nftDonationAmount);
    let [,,,from] = accounts;

    let balanceBefore = await ffERC721Instance.balanceOf(from);

    let value = web3.utils.toWei(".01", "ether");
    let data = web3.utils.toHex(1);

    await ffDonationInstance.sendTransaction({ from, value, data });
    let balanceAfter = await ffERC721Instance.balanceOf(from);
    assert.equal(web3.utils.fromWei(balanceBefore).toString(), 
        web3.utils.fromWei(balanceAfter).toString());
  });

  it("should split ERC20 token evenly among payees when given an evaluatorId", async () => {
    ffERC20Instance = await FFERC20.new(200, "FugueERC20", "XFF");
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 2, nftDonationAmount);

    await ffERC20Instance.transfer(ffDonationInstance.address, 20);
    await ffDonationInstance.transferERC20(ffERC20Instance.address, 1, 20, accounts[1]);
    balance4 = await ffERC20Instance.balanceOf(accounts[4]).then(result => {
        return result;
    });
    balance6 = await ffERC20Instance.balanceOf(accounts[6]).then(result => {
        return result;
    });
    let nftBalance = await ffERC721Instance.balanceOf(accounts[1]);

    assert.equal(Number(balance4), 10);
    assert.equal(Number(balance6), 10);
  });

  it("should allow a donor to send ERC20: APPROVE, TRANSFERFROM, ERC721", async () => {
    let [,from] = accounts;
    ffERC20Instance = await FFERC20.new(200, "FugueERC20", "XFF");
    await ffDonationInstance.setDonationDetails(ffERC721Instance.address, 2, nftDonationAmount);

    await ffERC20Instance.transfer(accounts[1], 20);
    await ffERC20Instance.approve(ffDonationInstance.address, 20);
    const balance1 = await ffERC20Instance.balanceOf(accounts[1]).then(result => {
        return result;
    });
    console.log(balance1);
    await ffDonationInstance.donateERC20(ffERC20Instance.address, 1, 20, {from});
    // const amount = await ffERC20Instance.allowance(accounts[1], ffERC20Instance.address);
    // console.log(amount);
    balance4 = await ffERC20Instance.balanceOf(accounts[4]).then(result => {
        return result;
    });
    balance6 = await ffERC20Instance.balanceOf(accounts[6]).then(result => {
        return result;
    });
    let nftBalance = await ffERC721Instance.balanceOf(accounts[1]);

    assert.equal(Number(balance4), 10);
    assert.equal(Number(balance6), 10);
  });
});
