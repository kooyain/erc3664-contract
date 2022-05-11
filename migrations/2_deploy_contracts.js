const Character = artifacts.require("Character");

module.exports = function (deployer) {
  deployer.deploy(Character);
};