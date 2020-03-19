const XFFToken = artifacts.require("XFFToken");

contract('XFFToken', (accounts) => {
  it('should have a name and symbol', async () => {
    const xffTokenInstance = await XFFToken.deployed();
    const name = await xffTokenInstance.name.call();
    const symbol = await xffTokenInstance.symbol.call();

    assert.equal(name, "Fugue Foundation", "Name error");
    assert.equal(symbol, "XFF", "Symbol error");
  });
});
