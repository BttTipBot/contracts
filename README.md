# Compile
```shell
npx hardhat compile --force
```

# Deploy the code

```shell
npx hardhat run --network bttcTestnet .\scripts\deploy.ts
```

```shell
npx hardhat run --network bttc .\scripts\deploy.ts
```

# Upgrade the code.
1.Modify the contract address in .\scripts\upgrade.ts 

```shell
npx hardhat run --network bttcTestnet .\scripts\upgrade.ts
```

```shell
npx hardhat run --network bttc .\scripts\upgrade.ts
```

# Publish and verify
```shell
npx hardhat verify --network bttcTestnet 0xa5019Fe2B0AF5EC39d1Eb6A23B44CcA8e3d889F5
npx hardhat verify --network bttc 0x9F05ff7dcF4b8d73b32eEBd7DE1D9C8F19cEd24d
```