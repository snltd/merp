#!/bin/sh -e

# Create a fresh zone which will be used to clone zones for testing. You
# probably need to be root to do this, and you definitely need to be in an
# illumos global zone.

SCRIPT=$(/bin/readlink -f "$0")
DIR=${SCRIPT%/*}
GURP_BIN="${DIR}/../gurp/target/debug/gurp"
GURP_FILE="${DIR}/template/functional-test-template.janet"
 
"$GURP_BIN" apply "$GURP_FILE"

