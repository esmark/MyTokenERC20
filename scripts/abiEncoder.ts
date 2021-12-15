import { ethers } from 'ethers';

async function main() {
    const address = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";
    const abicoder = ethers.utils.defaultAbiCoder.encode(["address"], [address]);
    console.log(abicoder);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
