#!/bin/sh -e

# Creates a fresh zone which will be used to clone zones for testing.
#
TEST_LIST="
  minidlna-wrapper.janet
"
  # workstation-wrapper.janet
 
SCRIPT=$(readlink -f $0)
DIR=${SCRIPT%/*}
export GURP_TEST_DIR=$DIR
GURP_BIN="${DIR}/../gurp/target/debug/gurp"
GURP_FILE="${DIR}/tests/test-basenode.janet"

if [[ $1 == "--debug" ]]
then
  LEVEL="debug"
else
  LEVEL="info"
fi

for test in $TEST_LIST
do
  RUST_LOG=$LEVEL $GURP_BIN apply "${DIR}/tests/${test}"
done

