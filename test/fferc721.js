const FFERC721 = artifacts.require("FFERC721");
const FFDonation = artifacts.require("FFDonation");
const tokenURI = "foo";

contract("FFERC721", async (accounts) => {
  let ffERC721Instance;

  beforeEach(async () => {
    ffERC721Instance = await FFERC721.new("FugueERC721", "FF");
  });

  it("should set name and symbol correctly", async () => {

    const name = await ffERC721Instance.name.call();
    const symbol = await ffERC721Instance.symbol.call();

    assert.equal(name, "FugueERC721");
    assert.equal(symbol, "FF");
  });

  it("should mint a token to msg.sender", async () => {

    let [,from] = accounts;
    let tokenId = await ffERC721Instance.awardNFT(from, tokenURI).then(result => {
        return result.logs[0].args.tokenId.toString();
    });
    assert.equal(tokenId, 1);
  });
});
