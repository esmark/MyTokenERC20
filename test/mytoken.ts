import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('Token contract', () => {
  let Token;
  let token: Contract;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;

  beforeEach(async () => {
    Token = await ethers.getContractFactory('MyToken');
    [owner, addr1, addr2] = await ethers.getSigners();
    token = await Token.deploy();

    // console.log('Token address: ' + token.address);
    // console.log('Token signer: ' + token.signer.toString());
    // const ownerBalance = await token.balanceOf(owner.address);
    // console.log('Owner balance: ' + ownerBalance);
});

  describe('Deployment', () => {
    it('Should set the right owner', async function () {
      expect(token.signer.toString()).to.equal(owner.address);
    });

    it('Should assign the total supply of tokens to the owner', async () => {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe('Transactions', () => {
    it('Should transfer tokens between accounts', async () => {
      await token.transfer(addr1.address, 50);
      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);

      await token.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it('Should fail if sender doesn’t have enough tokens', async () => {
      const initialOwnerBalance = await token.balanceOf(owner.address);

      await expect(
        token
          .connect(addr1)
          .transfer(owner.address, 100000000000)
      )
        .to
        .be
        .revertedWith('Not enough tokens');

      expect(
        await token.balanceOf(owner.address)
      )
        .to
        .equal(initialOwnerBalance);
    });

    it('Should  transfer addr1 to addr2', async () => {
      const initialAddr1Balance = await token.balanceOf(addr2.address);

      await token.transferFrom(addr1.address, addr2.address, 150);

      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(initialAddr1Balance - 150);

      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(150);

      const allowed = await token.allowed(addr1.address, addr1.address);
      expect(allowed).to.equal(150);
      
      await token.connect(addr1).transfer(addr2.address, 50);
      const balances = await token.balanceOf(addr2.address);
      expect(balances).to.equal(150);
    });

    it('Should update balances after transfers', async () => {
      const initialOwnerBalance = await token.balanceOf(owner.address);

      await token.transfer(addr1.address, 100);
      await token.transfer(addr2.address, 50);

      const finalOwnerBalance = await token.balanceOf(owner.address);
      expect(finalOwnerBalance).to.equal(initialOwnerBalance - 150);

      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(100);

      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });
  });

  describe('Approving', () => {
    it('Should approve 500 tokens to addr1 accounts', async () => {
      const approve = await token.approve(addr1.address, 500);
      expect(approve).to.equal(500);
    });

    it('Should send message about allowing 500 tokens to addr1 accounts', async () => {
      const allowed = await token.allowance(owner.address, addr1.address);
      expect(allowed).to.equal(500);
    });
  });
});