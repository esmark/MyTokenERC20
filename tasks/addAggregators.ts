import fs from 'fs';
import {task} from "hardhat/config";
import dotenv from 'dotenv';

task("addAggregators", "Add aggregators for assets and collateral")
    .setAction(async function (args, hre) {

        const network = hre.network.name;
        const envConfig = dotenv.parse(fs.readFileSync(`.env-${network}`));
        for (const parameter in envConfig) {
            process.env[parameter] = envConfig[parameter]
        }

        const lending = await hre.ethers.getContractAt(process.env.LENDING_NAME as string, process.env.LENDING_CONTRACT_ADDRESS as string);
        let input = {
            aggregators: ["0x007A22900a3B98143368Bd5906f8E17e9867581b", "0x0715A7794a1dc8e42615F059dD6e406A6594651A", "0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada"],
            tokens:["0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", "0x5FbDB2315678afecb367f032d93F642f64180aa3"]
        }
        await lending.addAggregators(input.aggregators, input.tokens);
    })