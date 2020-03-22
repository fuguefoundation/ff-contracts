// Create file in root dir (e.g., app.env) to include env variables
require('dotenv').config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

var mnemonic = process.env.SEED;
var infura = "https://goerli.infura.io/v3/" + process.env.INFURA_KEY;

module.exports = {
  networks: {
   development: {
     host: "127.0.0.1",
     port: 7545,
     network_id: "*"
   },
   metamask: {
     host: "127.0.0.1",
     port: 8545,
     network_id: "*"
   },
   goerli: {
     provider: function() {
       return new HDWalletProvider(mnemonic, infura)
     },
     network_id: 5,
   //   gas : 6700000,
   //   gasPrice : 10000000000
   }           
  }
  
};
