#!/bin/bash

set -eu
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/vars.sh

# Submit a transaction on stride to register the gaia host zone
printf "\nCreating host zone...\n"
$MAIN_STRIDE_CMD tx stakeibc register-host-zone \
    connection-0 $ATOM_DENOM cosmos $IBC_ATOM_DENOM channel-0 1 \
    --from $STRIDE_ADMIN_ACCT --gas 1000000 --home $SCRIPT_DIR/state/stride1 -y
CSLEEP 10

printf "\nRegistering validators...\n"
$MAIN_STRIDE_CMD tx stakeibc add-validator $GAIA_CHAIN_ID gval1 $GAIA_DELEGATE_VAL_1 10 5 --from $STRIDE_ADMIN_ACCT -y
CSLEEP 10
$MAIN_STRIDE_CMD tx stakeibc add-validator $GAIA_CHAIN_ID gval2 $GAIA_DELEGATE_VAL_2 10 10 --from $STRIDE_ADMIN_ACCT -y
CSLEEP 10

# sleep a while longer to wait for ICA accounts to set up
printf "\nWaiting for ICA accounts on host..."
while true; do
    if ! $MAIN_STRIDE_CMD q stakeibc list-host-zone | grep Account | grep -q null; then
        sleep 5
        break
    fi
done
