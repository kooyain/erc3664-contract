const Character = artifacts.require('Character');

contract("Character", async (accounts) => {
    it("Deploy success", async () => {
        character = await Character.deployed()
        let address = await character.address;

        assert.notEqual(address, 0x0);
        assert.notEqual(address, '');
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    });
});