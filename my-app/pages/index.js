import Head from "next/head";
import Image from "next/image";
import styles from "../styles/Home.module.css";
import React, { useState, useEffect, useRef } from "react";
import Web3Modal from "web3modal";
import { BigNumber, Contract, providers, utils } from "ethers";
import { HERO_CONTRACT_ADDRESS, HERO_ABI } from "../constants";
export default function Home() {
  //1. Check if user is signed in, if not prompt them sign in *
  //2. Check how many heroes the address has *
  //3. display those heroes
  //4. Set up on frontend to create a hero *
  // - Allow user to choose which class they would like to be *
  // - Call the contract to create the hero and ask for payment from user *
  // - Show pending transaction *
  // - Show the new hero that was created and the stats *

  const [walletConnected, setWalletConnected] = useState(false);
  const [usersOwnedHeroes, setUsersOwnedHeroes] = useState([]);
  const web3ModalRef = useRef(null);

  useEffect(async () => {
    if (!walletConnected) {
      web3ModalRef.current = new Web3Modal({
        network: "rinkeby",
        providerOptions: {},
        disableInjectedProvider: false,
      });
      connectWallet();
      getUsersHeroes();
    }
  }, [walletConnected]);

  useEffect(() => {
    displayUsersHeroes();
  }, [usersOwnedHeroes]);

  const getProviderOrSigner = async (needSigner = false) => {
    const provider = await web3ModalRef.current.connect();
    const web3Provider = new providers.Web3Provider(provider);
    const { chainId } = await web3Provider.getNetwork();
    if (chainId !== 4) {
      window.alert("Change the network to Rinkeby");
      throw new Error("Change network to Rinkeby");
    }

    if (needSigner) {
      const signer = web3Provider.getSigner();
      return signer;
    }
    return web3Provider;
  };

  const connectWallet = async () => {
    try {
      await getProviderOrSigner();
      setWalletConnected(true);
    } catch (err) {
      console.error(err);
    }
  };

  const getUsersHeroes = async () => {
    try {
      const signer = await getProviderOrSigner(true);
      const contract = new Contract(HERO_CONTRACT_ADDRESS, HERO_ABI, signer);
      const usersHeroes = await contract.getHeroes();
      const userHeroesWithStats = [];
      for (let index = 0; index < usersHeroes.length; index++) {
        const stats = await getHeroStats(usersHeroes[index]);
        userHeroesWithStats.push(stats);
      }
      if (userHeroesWithStats.length == 0) return;
      const heroCards = userHeroesWithStats.map((stats, index) => (
        <HeroCard heroStats={stats} key={index} />
      ));
      setUsersOwnedHeroes(heroCards);
    } catch (err) {
      console.error(err);
    }
  };

  const createHero = async (selectedClass) => {
    try {
      const signer = await getProviderOrSigner(true);
      const contract = new Contract(HERO_CONTRACT_ADDRESS, HERO_ABI, signer);
      await contract.createHero(selectedClass, {
        value: utils.parseEther("0.05"),
      });
      contract.on(contract.filters.heroCreated(), function (hero) {
        getUsersHeroes();
        console.log("heroCreated");
      });
    } catch (err) {
      console.error(err);
    }
  };

  const getHeroStats = async (hero) => {
    try {
      const provider = await getProviderOrSigner();
      const contract = new Contract(HERO_CONTRACT_ADDRESS, HERO_ABI, provider);
      const hexedHero = utils.hexlify(hero);
      const heroStats = {
        class: await contract.getHeroClass(hexedHero),
        strength: await contract.getStrength(hexedHero),
        dexterity: await contract.getDex(hexedHero),
        intelect: await contract.getIntelect(hexedHero),
        health: await contract.getHealth(hexedHero),
        magic: await contract.getMagic(hexedHero),
      };
      return heroStats;
    } catch (err) {
      console.error(err);
    }
  };

  const displayUsersHeroes = () => {
    if (usersOwnedHeroes.length == 0) return;
  };

  return (
    <main className={styles.container}>
      <button onClick={(e) => createHero(0)}>Mint Mage</button>
      <button onClick={(e) => createHero(1)}>Mint Healer</button>
      <button onClick={(e) => createHero(2)}>Mint Warrior</button>
      {usersOwnedHeroes}
    </main>
  );
}

const HeroCard = ({ heroStats }) => {
  let heroClass;
  switch (heroStats.class) {
    case 0:
      heroClass = "Mage";
      break;
    case 1:
      heroClass = "Healer";
      break;
    case 2:
      heroClass = "Warrior";
      break;
    case 3:
      heroClass = "Assassin";
      break;
    default:
      break;
  }

  return (
    <article>
      <h1>Class: {heroClass}</h1>
      <h6>Strength: {heroStats.strength}</h6>
      <h6>Magic: {heroStats.magic}</h6>
      <h6>Deterity: {heroStats.dexterity}</h6>
      <h6>Health: {heroStats.health}</h6>
      <h6>Intelect: {heroStats.intelect}</h6>
    </article>
  );
};
