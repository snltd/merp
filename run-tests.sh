#!/bin/sh -e

# Creates a fresh zone which will be used to clone zones for testing.
 
SCRIPT=$(readlink -f $0)
DIR=${SCRIPT%/*}
export GURP_TEST_DIR=$DIR
GURP_BIN="${DIR}/../gurp/target/debug/gurp"
GURP_FILE="${DIR}/tests/test-basenode.janet"

$GURP_BIN apply $GURP_FILE

