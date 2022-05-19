const { createInvalidExceptionError } = require("mocha/lib/errors");

const Character = artifacts.require('Character');

contract("Character", async (accounts) => {
    const owner = accounts[0]
    const user = accounts[1]
    const user2 = accounts[2]
    let contract
    

    it("Deploy success", async () => {
        contract = await Character.deployed();
        let address = await contract.address;

        assert.notEqual(address, 0x0);
        assert.notEqual(address, '');
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    });

    it("Mint Token", async () => {
        await contract.mint(user, 1, {from: user, value: web3.utils.toWei('0.005')})
        //console.log(gas) 
        let holder = await contract.ownerOf(1);
        var balance = await contract.balanceOf(holder)
        assert.equal(holder, user);
        assert.equal(balance, 1);
        await contract.mint(user, 2, {from: user, value: web3.utils.toWei('0.005')})
        balance = await contract.balanceOf(holder);
        assert.equal(balance, 2)
    });

    it("After Mint Attach sub Token", async () => {
        let subTokens = await contract.getSubTokens(1);
        assert.equal(subTokens.length, 2);
        assert.equal(subTokens[0], 8001);
        assert.equal(subTokens[1], 8002);
    });

    it("Separate Token", async () => {
        await contract.separate(1, {from: user});
        let subTokens = await contract.getSubTokens(1);
        assert.equal(subTokens.length, 0);
        assert.equal(await contract.ownerOf(8001), user);
        assert.equal(await contract.ownerOf(8002), user)
    });

    it("SeparateOne Token", async () => {
        await contract.separateOne(2, 8003, {from: user});
        let subTokens = await contract.getSubTokens(2);
        assert.equal(subTokens.length, 1)
        assert.equal(await contract.ownerOf(8003), user);
        assert.notEqual(await contract.ownerOf(8004), user);
    });

    it("combine Token", async () => {
        let subIds = [8001, 8002];
        let address = await contract.address;
        await contract.combine(1, subIds, {from: user});
        let subTokens = await contract.getSubTokens(1);
        assert.equal(subTokens.length, 2);
        assert.equal(await contract.ownerOf(8001), address);
        assert.equal(await contract.ownerOf(8002), address);
    });

    it("before transfer", async () => {
        await contract.safeTransferFrom(user, user2, 1, {from: user});
        assert.equal(await contract.ownerOf(1), user2);
        let synthesizedTokens = await contract.getSynthesizedTokens(1);
        synthesizedTokens.forEach(element => {
            assert.equal(element.owner, user2);
        });
    });
});