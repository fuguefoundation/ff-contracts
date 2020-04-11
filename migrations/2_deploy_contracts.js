//const XFFToken = artifacts.require("XFFToken");
const FFKudos = artifacts.require("FFKudos");
const FFPaymentSplit = artifacts.require("FFPaymentSplit");
const name = "FugueFoundation";
const symbol = "FF";
const payees = [
    "0x1356902d01d78714aa336f90099760ceaa3dbea4",
    "0x6526713b350083ac5812c837591d8456c5e64db6",
    "0xdc8f54f98f828da9e7ae30de176bc4108cd94599"
]
const shares = [3, 2, 1];

module.exports = function(deployer, network) {

    // console.log(`${"-".repeat(30)}
    // DEPLOYING XFFToken Contract...\n
    // Using ` + network + ` network\n`);

    // deployer.deploy(XFFToken, name, symbol);

    console.log(`${"-".repeat(30)}
    DEPLOYING FFKudos Contract...\n
    Using ` + network + ` network\n`);

    deployer.deploy(FFKudos, name, symbol);

    console.log(`${"-".repeat(30)}
    DEPLOYING FFPaymentSplit Contract...\n`);

    deployer.deploy(FFPaymentSplit, payees, shares);
};
