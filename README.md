## Usage

```
cd solidity
forge test --via-ir -vvvv
```

- You can modify the example in [`solidity/test/Shamir.t.sol`](solidity/test/Shamir.t.sol)

## TODO Suave

- [ ] the shares arrays `sharesA` and `sharesB` should be distributed across multiple kettles, as many as there are shares ideally

## Future work

- [ ] implement a better protocol such as SPDZ
- [ ] leverage SGX's capabilities such as access to source of randomness to implement trusted dealer
- [ ] DKG protocol
- [ ] more ideas about synergy between SGX and MPC protocols

