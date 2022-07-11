#!/usr/bin/env bats

setup_file() {
  # get the containing directory of this file
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  PATH="$SCRIPT_DIR/../../:$PATH"

  # set allows us to export all variables in account_vars
  set -a
  source scripts-local/account_vars.sh

  GETBAL() {
    head -n 1 | grep -o -E '[0-9]+'
  }
  GETSTAKE() {
    tail -n 2 | head -n 1 | grep -o -E '[0-9]+' | head -n 1
  }
  INIT_STAKE=$($GAIA_CMD q staking delegation $DELEGATION_ICA_ADDR $GAIA_DELEGATE_VAL | GETSTAKE)
  set +a
}

setup() {
  # get the containing directory of this file
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  PATH="$SCRIPT_DIR/../../:$PATH"

  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
}

@test "address names are correct" {
  assert_equal $STRIDE_VAL_ADDR "stride1uk4ze0x4nvh4fk0xm4jdud58eqn4yxhrt52vv7"

  assert_equal $GAIA_VAL_ADDR "cosmos1pcag0cj4ttxg8l7pcg0q4ksuglswuuedcextl2"
  assert_equal $GAIA_VAL_2_ADDR "cosmos133lfs9gcpxqj6er3kx605e3v9lqp2pg54sreu3"
  assert_equal $GAIA_VAL_3_ADDR "cosmos1fumal3j4lxzjp22fzffge8mw56qm33h9ez0xy2"

  assert_equal $HERMES_STRIDE_ADDR "stride1ft20pydau82pgesyl9huhhux307s9h3078692y"
  assert_equal $ICQ_STRIDE_ADDR "stride12vfkpj7lpqg0n4j68rr5kyffc6wu55dzqewda4"
}

# @test "ibc transfer updates all balances" {
#   # get initial balances
#   str1_balance=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom ustrd | GETBAL)
#   gaia1_balance=$($GAIA_CMD q bank balances $GAIA_ADDRESS --denom $IBC_STRD_DENOM | GETBAL)
#   str1_balance_atom=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom $IBC_ATOM_DENOM | GETBAL)
#   gaia1_balance_atom=$($GAIA_CMD q bank balances $GAIA_ADDRESS --denom uatom | GETBAL)
#   # do IBC transfer
#   $STRIDE_CMD tx ibc-transfer transfer transfer channel-0 $GAIA_ADDRESS 10000ustrd --from val1 --chain-id STRIDE -y --keyring-backend test
#   $GAIA_CMD tx ibc-transfer transfer transfer channel-0 $STRIDE_ADDRESS 10000uatom --from gval1 --chain-id GAIA -y --keyring-backend test
#   sleep 30
#   # get new balances
#   str1_balance_new=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom ustrd | GETBAL)
#   gaia1_balance_new=$($GAIA_CMD q bank balances $GAIA_ADDRESS --denom $IBC_STRD_DENOM | GETBAL)
#   str1_balance_atom_new=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom $IBC_ATOM_DENOM | GETBAL)
#   gaia1_balance_atom_new=$($GAIA_CMD q bank balances $GAIA_ADDRESS --denom uatom | GETBAL)
#   # get all STRD balance diffs
#   str1_diff=$(($str1_balance - $str1_balance_new))
#   gaia1_diff=$(($gaia1_balance - $gaia1_balance_new))
#   assert_equal "$str1_diff" '10000'
#   assert_equal "$gaia1_diff" '-10000'
#   # get all ATOM_DENOM balance diffs
#   str1_diff=$(($str1_balance_atom - $str1_balance_atom_new))
#   gaia1_diff=$(($gaia1_balance_atom - $gaia1_balance_atom_new))
#   assert_equal "$str1_diff" '-10000'
#   assert_equal "$gaia1_diff" '10000'
# }

# @test "liquid stake mints stATOM" {
#   # get module address 
#   MODADDR=$($STRIDE_CMD q stakeibc module-address stakeibc | awk '{print $NF}') 
#   # get initial balances
#   mod_balance_atom=$($STRIDE_CMD q bank balances $MODADDR --denom $IBC_ATOM_DENOM | GETBAL)
#   str1_balance_atom=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom $IBC_ATOM_DENOM | GETBAL)
#   str1_balance_statom=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom $STATOM_DENOM | GETBAL)
#   # liquid stake
#   $STRIDE_CMD tx stakeibc liquid-stake 1000 uatom --keyring-backend test --from val1 -y --chain-id $STRIDE_CHAIN
#   BLOCK_SLEEP 1
#   # make sure Module Acct received ATOM_DENOM - remove if IBC transfer is automated
#   # mod_balance_atom_new=$($STRIDE_CMD q bank balances $MODADDR --denom $IBC_ATOM_DENOM | GETBAL)
#   # mod_atom_diff=$(($mod_balance_atom_new - $mod_balance_atom))
#   # assert_equal "$mod_atom_diff" '1000'
#   # make sure IBC_ATOM_DENOM went down 
#   str1_balance_atom_new=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom $IBC_ATOM_DENOM | GETBAL)
#   str1_atom_diff=$(($str1_balance_atom - $str1_balance_atom_new))
#   assert_equal "$str1_atom_diff" '1000'
#   # make sure STATOM went up
#   str1_balance_statom_new=$($STRIDE_CMD q bank balances $STRIDE_ADDRESS --denom $STATOM_DENOM | GETBAL)
#   str1_statom_diff=$(($str1_balance_statom_new-$str1_balance_statom))
#   assert_equal "$str1_statom_diff" "1000"
# }


# # add test to register host zone 
@test "host zone successfully registered" {
  run $STRIDE_CMD q stakeibc show-host-zone GAIA
  assert_line '  HostDenom: uatom'
  assert_line '  chainId: GAIA'
  assert_line '  delegationAccount:'
  assert_line '    address: cosmos19l6d3d7k2pel8epgcpxc9np6fsvjpaaa06nm65vagwxap0e4jezq05mmvu'
  assert_line '  feeAccount:'
  assert_line '    address: cosmos1x0d2ay0xs9t40ah965ey2ufucmcea39cq28r7ud56ta388pjjhwsxqugxe'
  assert_line '  redemptionAccount:'
  assert_line '    address: cosmos1nc4hn8s7zp62vg4ugqzuul84zhvg5q7srq00f792zzmf5kyfre6sxfwmqw'
  assert_line '  withdrawalAccount:'
  assert_line '    address: cosmos1lcnmjwjy2lnqged5pnrc0cstz0r88rttunla4zxv84mee30g2q3q48fm53'
  assert_line '  unbondingFrequency: "3"'
  assert_line '  RedemptionRate: "1.000000000000000000"'
}

# # add test to see if assets are properly being staked on host zone
# @test "tokens staking on host zone" {
#   # run below test once ICQ is deployed
#   sleep 60
#   NEW_STAKE=$($GAIA_CMD q staking delegation $DELEGATION_ICA_ADDR $GAIA_DELEGATE_VAL | GETSTAKE)
#   stake_diff=$((($NEW_STAKE - $INIT_STAKE) > 0))
#   assert_equal "$stake_diff" "1"
# }

# TEST-74
# add test to see if assets are properly being staked on host zone
# add asset redemption test

# @test "icq: exchange rate and delegated balance queries" {
#   # Test: query exchange rate
#   $STRIDE_CMD tx interchainquery query-exchangerate GAIA --keyring-backend test -y --from val1
#   sleep 15
#   run $STRIDE_CMD q txs --events message.action=/stride.interchainquery.MsgSubmitQueryResponse --limit=1
#   assert_line --partial 'key: redemptionRate'

#   # Test query delegated balance
#   $STRIDE_CMD tx interchainquery query-delegatedbalance GAIA --keyring-backend test -y --from val1
#   sleep 15
#   run $STRIDE_CMD q txs --events message.action=/stride.interchainquery.MsgSubmitQueryResponse --limit=1
#   assert_line --partial 'key: totalDelegations'
# }

# @test "exchange rate" {
#  # Test: liquid stake
#  # TODO(VISHAL) write a proper test here
# RR=$($STR1_EXEC q stakeibc list-host-zone | grep -Fiw 'RedemptionRate' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
# UDBAL=$($GAIA_CMD q bank balances $DELEGATION_ICA_ADDR | grep -Fiw 'amount:' | tr -dc '0-9')
# DBAL=$($GAIA_CMD q staking delegations $DELEGATION_ICA_ADDR | grep -Fiw 'amount:' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
# STSUPPLY=$($STR1_EXEC q bank balances $STRIDE_ADDR | grep -Fiw 'stuatom' -B 1 | tr -dc '0-9')
# BAL=$(( $UDBAL + $DBAL ))
# echo $BAL"="$STSUPPLY"*"$RR
# }

