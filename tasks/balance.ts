import { BigNumber, ethers } from 'ethers';
import { task } from 'hardhat/config';

task("balance", 'Prints the balance of assigned address')
  .addParam("account", "The account's address")
  .setAction(async (taskArgs, hre) => {
    const balance: BigNumber = await hre.ethers.provider.getBalance(taskArgs.account);
    const met = ethers.utils.formatUnits(balance, 0);
    console.log(taskArgs.account, met, "MET");
});