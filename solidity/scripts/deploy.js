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
    [75, 50, 125] // Attack Damage
  );
  await gameContract.deployed();

  console.log("Contract deployed to address: ", gameContract.address)

  let transaction;

  transaction = await gameContract.mintChampionNFT(0);
  await transaction.wait();
  console.log("Minted NFT Champion #1")

  transaction = await gameContract.mintChampionNFT(1);
  await transaction.wait();
  console.log("Minted NFT Champion #2")

  transaction = await gameContract.mintChampionNFT(2);
  await transaction.wait();
  console.log("Minted NFT Champion #3")

  console.log("Done deploying and minting!")
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