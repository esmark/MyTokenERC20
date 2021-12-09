import fs from 'fs';
import {task} from "hardhat/config";
import dotenv from 'dotenv';

task("addAssets", "Add assets")
    .setAction(async function (args, hre) {

        const network = hre.network.name;
        const envConfig = dotenv.parse(fs.readFileSync(`.env-${network}`));
        for (const parameter in envConfig) {
            process.env[parameter] = envConfig[parameter]
        }

        const lending = await hre.ethers.getContractAt(process.env.LENDING_NAME as string, process.env.LENDING_CONTRACT_ADDRESS as string);
        let input = {
            tokens:["0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"],
            quotients: [120, 150]
        }
        await lending.addAssets(input.tokens, input.quotients);
    })