module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
  const { log } = deployments
  const { deploy } = deployments

  const namedAccounts = await getNamedAccounts()
  log(namedAccounts)
  const { deployer } = namedAccounts

  const deployResult = await deploy("NFTokenMetaEnumerable", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  })
  if (deployResult.newlyDeployed) {
    log(
      `contract NFTokenMetaEnumerable deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    )
  }
}
module.exports.tags = ["NFTokenMetaEnumerable"]
