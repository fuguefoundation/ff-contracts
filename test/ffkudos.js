const FFKudos = artifacts.require("FFKudos");

contract('FFKudos', (accounts) => {
  it('should have a name and symbol', async () => {
    const ffKudosInstance = await FFKudos.deployed();
    const name = await ffKudosInstance.name.call();
    const symbol = await ffKudosInstance.symbol.call();

    assert.equal(name, "FugueFoundation", "Name error");
    assert.equal(symbol, "FF", "Symbol error");
  });
});
