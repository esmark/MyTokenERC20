import { BigNumber, ethers } from 'ethers';
import { task } from 'hardhat/config';

task("balances", 'Prints the balances of each addresses')
  .setAction(async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
  
    for (const account of accounts) {
        const balance: BigNumber = await hre.ethers.provider.getBalance(account.address);
        const met = ethers.utils.formatUnits(balance, 0);
        console.log(account.address, met, "MET");
        //   console.log(account.address);
    }
});