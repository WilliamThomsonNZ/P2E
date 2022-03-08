import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter";

//When we run the npx hardhat command, hardhat grabs the config and then loads in those libraries. 
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: "0.8.10",
  networks: {
    hardhat: {
      chainId: 1337
    } 
  }
};
