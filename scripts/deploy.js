const hre = require('hardhat');

async function main() {
  /*
    user1 => receiver1
    user2 => spender
    user3 => receiver2
  */
  const [contractOwner, user1, user2, user3] = await hre.ethers.getSigners();

  const Erc20 = await hre.ethers.getContractFactory('Erc20');
  const erc20 = await Erc20.deploy('Crypto Rupee Index', 'CRE8', 18, 1000000);
  await erc20.deployed();

  console.log('Contract Address', erc20.address);

  const contractOwnerBalance1 = await erc20.balanceOf(contractOwner.address);
  const receiver1Balance1 = await erc20.balanceOf(user1.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
