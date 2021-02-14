// const FFKudos = artifacts.require("FFKudos");
const FFERC20 = artifacts.require("FFERC20");
const FFERC721 = artifacts.require("FFERC721");
const FFDonation = artifacts.require("FFDonation");
// const name = "FugueFoundation";
// const symbol = "FF";
const initialSupply = 200;
const erc20Name = "FFToken";
const erc20Symbol = "XFF";
const erc721Name = "FF721";
const erc721Symbol = "FF";
const payees = [
    "0xa1E7241F2c8D02Acb18fc17259E88253B7e023b7", //1 Against Malaria Foundation
    "0x0b15B6192Cc82A6f7BBE945E249Edaca3E7Edde4", //1 Helen Keller Int
    "0x446bb02a2f21b395B166765A73cC54Bc7BB0a7EE", //1 Deworm the World
    "0xD3f4370F33627840C54361823971Ace0D433Be1e", //1 SCI Foundation
    "0x19E2fDc9b06E36b691Cc08BaC531eEBF0ac15164", //1 Sightsavers
    "0xad77a20752D0cD9c7de6a5C82Dc2885a5ED1621B", //1 END Fund
    "0xAD53Fc82cC6bd1447FcDf66e6A85DAABC0440343", //1 Give Directly
    "0x1d7bD68dcC3e2766846CBDf83E9CEEC422c36Bd0", //1 Malaria Consortium
    "0x143Ee9c8c36BBF9AAE54c68f05d4CA11d805420B", //2 Fistula
    "0x8D2b33989f0B17Bc110f301EAB47c791629FA128", //2 Living Goods
    "0x3D78DC0605ecFD2FF25f2fec9741691D19824812", //2 Oxfam
    "0x009805716c9DC414E7fE71A4B264E32BB80268C6", //2 Population Services Int
    "0xfA1e95e226cef05A135e04e08eBC60Eb7bEa0143", //2 Village Enterprise
    "0x307181285538917c1e200675965D3461Ae7fd596", //3 Johns Hopkins
    "0xE9598FAA6fC246DBf81C56e2bE6cf9Ee2536596d", //3 Gates Foundation
    "0x3195298fcFe9772aC77aA9865E7e8072C51938bf", //3 Center for Global Dev
    "0xF0a9b6973B10406FF73615Ca7f1C36E967624F4A", //4 Albert Schweitzer
    "0x743aE4428De6D4d9F4f1f84CDbBC2A20a70Db3C4", //4 Anima Int
    "0x6B7d03B1273Cbf60823d4E05632a2415c398A389", //4 Humane League
    "0x80085E036647c9FBe30803d944cb0311464F8636" ///4 Good Food Institute
]

const evaluatorIds = [
    1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2,
    3, 3, 3,
    4, 4, 4, 4
];

module.exports = function(deployer, network) {

    // console.log(`${"-".repeat(30)}
    // DEPLOYING FFKudos Contract...\n
    // Using ` + network + ` network\n`);

    // deployer.deploy(FFKudos, name, symbol);

    console.log(`${"-".repeat(30)}
    DEPLOYING FFERC721 Contract...\n
    Using ` + network + ` network\n`);

    deployer.deploy(FFERC721, erc721Name, erc721Symbol);

    console.log(`${"-".repeat(30)}
    DEPLOYING FFERC20 Contract...\n
    Using ` + network + ` network\n`);

    deployer.deploy(FFERC20, initialSupply, erc20Name, erc20Symbol);

    console.log(`${"-".repeat(30)}
    DEPLOYING FFDonation Contract...\n`);

    deployer.deploy(FFDonation, payees, evaluatorIds);
};
