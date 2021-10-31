const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyNFTBattler');
  const gameContract = await gameContractFactory.deploy(
    ["Caitlyn", "Vex", "Akali"], // Names
    [
      "http://ddragon.leagueoflegends.com/cdn/11.21.1/img/champion/Caitlyn.png",
      "http://ddragon.leagueoflegends.com/cdn/11.21.1/img/champion/Vex.png",
      "http://ddragon.leagueoflegends.com/cdn/11.21.1/img/champion/Akali.png"
    ], // Images
    [150, 200, 100], // HP Value
    [75, 50, 125], // Attack Damage
    "Christmas Poro", // Boss Name
    "http://ddragon.leagueoflegends.com/cdn/11.21.1/img/profileicon/588.png", // Boss Image
    "10000", // Boss HP
    "10" // Boss Damage
  );

  await gameContract.deployed();
  console.log("Contract deployed to address: ", gameContract.address)
  
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();