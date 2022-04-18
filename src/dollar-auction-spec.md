# dollar auction contract

## constructor

- admin address
- staking address
- split amount (portion paid to staking contract)
- round length
- starting amount given to first bidder
- oracle contract address

## disperse funds function

- checks if auction over
- sends portion of total to:
  - sends to staking contract
  - sends to admin multisig

## bid

- checks if bid greater than last
- gives one WAG
- add bid to pot
- adjust bidder's place in top five if needed

## round function

- checks if auction over
- gets random value from oracle
- picks random loser from place 3-5
- adds random loser total bid to pot
- adds guaranteed loser total bid to pot
- gives prize to winner
- calls disperse funds

## add to price function

- adds MATIC to total pot
