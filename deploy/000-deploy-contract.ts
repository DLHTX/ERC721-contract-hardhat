module.exports = async ({ ethers, getNamedAccounts, deployments }) => {
  const { log } = deployments
  log(123)
  console.log(123)
  const { deploy } = deployments

  const namedAccounts = await getNamedAccounts()
  log(namedAccounts)
  const { deployer } = namedAccounts

  const deployResult = await deploy("ExampleToken", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  })
  if (deployResult.newlyDeployed) {
    log(
      `contract ExampleToken deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    )
  }
}
module.exports.tags = ["ExampleToken"]
