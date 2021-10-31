const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyNFTBattler');
  const gameContract = await gameContractFactory.deploy();
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
