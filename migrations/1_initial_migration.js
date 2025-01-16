var ZombieOwnership = artifacts.require("./Daobuilder.sol");

module.exports =  (deployer => {
  deployer.then(async () => {
      await deployer.deploy(ZombieOwnership);
  });
});