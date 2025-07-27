#!/bin/sh -e

# Set up everything we need to run Gurp tests in a fresh zone. Requires a local
# Janet/JPM installation and gcc, and expects a gurp repo checked out at the
# same level as this one.

SCRIPT=$(/bin/readlink -f "$0")
DIR=${SCRIPT%/*}
GURP_BIN="${DIR}/../gurp/target/debug/gurp"
GURP_FILE="${DIR}/template/functional-test-template.janet"

cd "${DIR}/template/files"

# Copy in a Janet binary and set up JPM modules

cp -p "$(which janet)" "${DIR}/template/files/janet"
jpm deps -l

# Create a fresh zone which will be used to clone zones for testing.
 
"$GURP_BIN" apply "$GURP_FILE"

