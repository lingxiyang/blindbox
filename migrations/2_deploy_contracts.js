
const BlindBox = artifacts.require("BlindBox");
module.exports = function(deployer) {
  const name ="demo_cc";
  const symbole ="cc";
  //?filename=mainnet-chainlink-elf.json
  const baseUrl = "https://ipfs.io/ipfs/QmT3nSKpJrEUWgeqGNiQPNEWcP2cousZNfQ72qX8qnBtWk";
  const notRevealUrl = "https://ipfs.io/ipfs/QmT3nSKpJrEUWgeqGNiQPNEWcP2cousZNfQ72qX8qnBtWk"
  deployer.deploy(BlindBox,name,symbole,baseUrl,notRevealUrl);
};
