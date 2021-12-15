import { ethers } from 'ethers';

async function main() {
    const string = "Trump";
    const byte32 = ethers.utils.formatBytes32String(string);
    console.log(string, "=>", byte32);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
