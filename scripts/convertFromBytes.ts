import { ethers } from 'ethers';

async function main() {
    //0x5472756d70000000000000000000000000000000000000000000000000000000
    const byte32 = "0x426964656e000000000000000000000000000000000000000000000000000000";
    const string = ethers.utils.parseBytes32String(byte32);
    console.log(byte32, "=>", string);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
