# EnergyMarket

This is an Ethereum project that implements an Energy Market

## Usage

0. The contract, when inititlaised with the `_initialSupply` and `_basePrice` will mint to the network that same amount of tokens and will establish the base energy price. 

1. You can `produce` energy, and you will receive back tokens, according to the unit energy price at a certain time slot.

2. You can `consume` energy, and you will be charged tokens for the unit of energy you consume. Must have approved the contract to spend your tokens preliminarily.

3. You can at any time query the production and consumtion prices with `getProductionPrice` and `getConsumptionPrice`.