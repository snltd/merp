#!/bin/sh -e

# Creates a fresh zone which will be used to clone zones for testing.

TEST_ZFS_DATASET="rpool/test-zone-dataset"

 
SCRIPT=$(readlink -f $0)
DIR=${SCRIPT%/*}
export GURP_TEST_DIR=$DIR
GURP_BIN="${DIR}/../gurp/target/debug/gurp"
GURP_FILE="${DIR}/tests/test-basenode.janet"

TEST_LIST="$(ls ${DIR}/tests/*wrapper.janet)"

if [[ $1 == "--debug" ]]
then
  LEVEL="debug"
  DEBUG_OPT="--debug"
  shift
else
  LEVEL="info"
fi

# This gets left behind when tests fail
if zfs list $TEST_ZFS_DATASET >/dev/null 2>&1
then
  if zoneadm -z gurp-test-zone list >/dev/null 2>&1
  then
    print "halting test zone"
    zoneadm -z gurp-test-zone halt
  fi
  
  print "cleaning up $TEST_ZFS_DATASET"
  zfs destroy -r $TEST_ZFS_DATASET >/dev/null 2>&1
fi

if [[ $# == 1 ]]
then
  TEST_LIST=$@
fi

for test in $TEST_LIST
do
  RUST_LOG=$LEVEL $GURP_BIN apply ${DEBUG_OPT} -L${DIR}/../gurp/janet_src/lib/gurp.janet $test || exit 4
done

