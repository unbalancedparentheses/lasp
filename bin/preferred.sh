#!/usr/bin/env bash

source helpers.sh

ENV_VARS=(
  DCOS
  TOKEN
  EVALUATION_PASSPHRASE
  ELB_HOST
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
)

for ENV_VAR in "${ENV_VARS[@]}"
do
  if [ -z "${!ENV_VAR}" ]; then
    echo ">>> ${ENV_VAR} is not configured; please export it."
    exit 1
  fi
done

EVAL_NUMBER=1
SIMULATION=ad_counter
CLIENT_NUMBER=300
HEAVY_CLIENTS=false
PARTITION_PROBABILITY=0
AAE_INTERVAL=10000
DELTA_INTERVAL=10000
INSTRUMENTATION=true
LOGS="s3"
EXTENDED_LOGGING=true

declare -A EVALUATIONS

## peer_to_peer_delta_based_with_aae_test
EVALUATIONS["peer_to_peer_delta_based_with_aae"]="partisan_hyparview_peer_service_manager delta_based false"

for i in $(seq 1 $EVAL_NUMBER)
do
  echo "Running evaluation $i of $EVAL_NUMBER"

  for EVAL_ID in "${!EVALUATIONS[@]}"
  do
    STR=${EVALUATIONS["$EVAL_ID"]}
    IFS=' ' read -a CONFIG <<< "$STR"
    PEER_SERVICE=${CONFIG[0]}
    MODE=${CONFIG[1]}
    BROADCAST=${CONFIG[2]}
    TIMESTAMP=$(date +%s)

    PEER_SERVICE=$PEER_SERVICE MODE=$MODE BROADCAST=$BROADCAST SIMULATION=$SIMULATION EVAL_ID=$EVAL_ID EVAL_TIMESTAMP=$TIMESTAMP CLIENT_NUMBER=$CLIENT_NUMBER HEAVY_CLIENTS=$HEAVY_CLIENTS PARTITION_PROBABILITY=$PARTITION_PROBABILITY AAE_INTERVAL=$AAE_INTERVAL DELTA_INTERVAL=$DELTA_INTERVAL INSTRUMENTATION=$INSTRUMENTATION LOGS=$LOGS AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY ./dcos-deploy.sh

    echo "Running $EVAL_ID with $CLIENT_NUMBER clients with configuration $STR"

    wait_for_completion
  done
done
