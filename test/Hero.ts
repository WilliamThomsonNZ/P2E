import "@nomiclabs/hardhat-ethers";
import {ethers} from "hardhat";
import { expect } from "chai";
import { create } from "domain";

describe("Hero" , function(){
    async function createHero(){
        const Hero = await ethers.getContractFactory("TestHero");
        const hero = await Hero.deploy();
        await hero.deployed();

        return hero;
    }
    let hero;
    before(async function () {
        hero = await createHero()
    })
    it("should get a zero hero array.", async function(){
        expect(await hero.getHeroes()).to.deep.equal([]);
    })
    it("should fail at createing hero cause of payment", async function(){
        let e;

        try {
            await hero.createHero(0, {
                value: ethers.utils.parseEther("0.04")
            });
        }catch(err){
            e = err;
        }
        expect(e.message.includes("You need to send at least 0.05 to create a hero")).to.equal(true);

    })
    it("should fail at createing hero cause of payment", async function(){
        const heroContract = await createHero();
        await heroContract.setRandom(69); 
        await heroContract.createHero(2, {
            value: ethers.utils.parseEther("0.05")
        });
        const hero = (await heroContract.getHeroes())[0];
        expect(await heroContract.getMagic(hero)).to.equal(16);
    })

    it("should return the class of the hero", async function(){
        //1. setup
        //2. deploy our contract
        //3. call our functions to test
        const heroContract = await createHero();
        await heroContract.setRandom(69);
        await heroContract.createHero(2, {
            value: ethers.utils.parseEther("0.05")
        })
        const hero = (await heroContract.getHeroes())[0];
        const heroClass = await heroContract.getHeroClass(hero);
        expect(heroClass).to.equal(0);
    })
})