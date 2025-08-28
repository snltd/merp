#!/bin/sh -e

# For multiple Gurp zone configurations, clones the template zone, applies a
# Gurp configuration, and tests the outcome.
#
# Optional arg 1: --debug, sets RUST_LOG to debug and enables --dump-config

TEMPLATE_ZONE="merp-template"
TEST_ZFS_DATASET="rpool/test-zone-dataset"
TEST_ZONE="merp-zone"
 
SCRIPT=$(readlink -f $0)
DIR=${SCRIPT%/*}
export GURP_TEST_DIR=$DIR
GURP_BIN="${DIR}/../gurp/target/debug/gurp"
GURP_FILE="${DIR}/tests/test-basenode.janet"

TEST_LIST="$(ls ${DIR}/tests/*wrapper.janet)"

if [[ $1 == "--debug" ]]
then
  LEVEL="debug"
  DEBUG_OPT="--dump-config"
  shift
else
  LEVEL="info"
fi

# This gets left behind when tests fail
if zfs list $TEST_ZFS_DATASET >/dev/null 2>&1
then
  if zoneadm -z $TEST_ZONE list >/dev/null 2>&1
  then
    print "halting $TEST_ZONE "
    zoneadm -z $TEST_ZONE halt
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

