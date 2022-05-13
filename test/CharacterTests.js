const Character = artifacts.require('Character');

contract("Character", async (accounts) => {
    const owner = accounts[0]
    const user = accounts[1]

    it("Deploy success", async () => {
        character = await Character.deployed()
        let address = await character.address;

        assert.notEqual(address, 0x0);
        assert.notEqual(address, '');
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    });

    it("Mint Token", async () => {
        console.log(user)
        await character.mint(user, 1 ,{from: user, value: web3.utils.toWei('0.005')})
        //console.log(gas) 
    })
});