import "@nomiclabs/hardhat-ethers";
import {ethers} from "hardhat";

async function deploy(){
    const Hero = await ethers.getContractFactory("Hero");
    const hero = await Hero.deploy();
    await hero.deployed();
    console.log("Hero contract address: ", hero.address)
    return hero;
}

deploy()