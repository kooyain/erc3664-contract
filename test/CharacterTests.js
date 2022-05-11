const Character = artifacts.require('Character');

contract("Character", async accounts => {
    it("Deploy success", async () => {
        let contract = await Character.deployed();
        let address = await contract.address;

        assert.notEqual(address, 0x0);
        assert.notEqual(address, '');
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    });
});