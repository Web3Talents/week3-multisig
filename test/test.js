const { expect } = require("chai");
const { ethers } = require("ethers");

describe("Multisig Wallet", async function(){
    beforeEach(async function () {
        
        // await minter.deployed();
        const token = await hre.ethers.getContractFactory("myCoin")
        mToken = await token.deploy();
        [owner, user1, user2] = await hre.ethers.getSigners();
        const wallet = await hre.ethers.getContractFactory("Multisig");
        mWallet = await wallet.deploy(user1.address);
        
    })
    it("Owners should be able to set token allowed", async function(){
       await mWallet.setAcceptedTokens(mToken.address);
       
        expect(await mWallet.acceptedToken(mToken.address)).to.be.equal(true)
    })
    it("Should be able to receive tokens from users", async function () {
       await mWallet.setAcceptedTokens(mToken.address);
       await  mToken.approve(mWallet.address, 10000000)
       await mWallet.depositFunds(200)

        expect((await mToken.balanceOf(mWallet.address)).toString()).to.equal((200).toString())
    })
    it("Should be able to initiate a withdrawal", async function(){
        await mWallet.setAcceptedTokens(mToken.address);
       await  mToken.approve(mWallet.address, 10000000)
       await mWallet.depositFunds(200)

       await mWallet.initiateWithdrawal(mToken.address, user2.address,50)
        expect((await mWallet.transactionDetails(1)).amount.toString()).to.equal("50")
    })
    it("Should be able to approve and complete a transaction", async function(){
        await mWallet.setAcceptedTokens(mToken.address);
       await  mToken.approve(mWallet.address, 10000000)
       await mWallet.depositFunds(200)

       await mWallet.initiateWithdrawal(mToken.address, user2.address,50)
        
       await mToken.connect(user2).approve(mWallet.address,1000000)
       await mWallet.connect(user1).completeWithdrawal(1)

       expect((await mToken.balanceOf(user2.address)).toString()).to.equal("50")
    })
})