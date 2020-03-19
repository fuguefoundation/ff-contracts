const XFFToken = artifacts.require("XFFToken");
const FFPaymentSplit = artifacts.require("FFPaymentSplit");
const name = "FugueFoundation";
const symbol = "XFF";
const payees = [
    "0x4B4FA37e6aD03d46894E5a96dAe7D2d88772C7f5",
    "0x79E0A49Bb424Ea66bada063d909a8AaCd1b12aB9",
    "0xD1466BfF24fEcae1D541D8FDd75a644686Aff976"
]
const shares = [3, 2, 1]

module.exports = function(deployer, network) {

    console.log(`${"-".repeat(30)}
    DEPLOYING XFFToken Contract...\n
    Using ` + network + ` network\n`);

    deployer.deploy(XFFToken, name, symbol);

    console.log(`${"-".repeat(30)}
    DEPLOYING FFPaymentSplit Contract...\n`);

    deployer.deploy(FFPaymentSplit, payees, shares);
};
