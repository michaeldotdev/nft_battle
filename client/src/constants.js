const CONTRACT_ADDRESS = '0x5D9C40271122C4EB13AF0BADCC116A134c5b3a0A';

const transformCharacterData = (characterData) => {
  return {
    name: characterData.name,
    imageURI: characterData.imageURI,
    currentHP: characterData.currentHP.toNumber(),
    maxHP: characterData.maxHP.toNumber(),
    attackDamage: characterData.attackDamage.toNumber(),
  };
};

export { CONTRACT_ADDRESS, transformCharacterData };