#!/bin/bash
set -eu

INFILE=$1
START_INDEX=$2

# Hard-coded in this script
PARTITION="by_drug"

OUTFILE=dataset.h5
GLOBAL_PREFIX="."
# "/lus/gila/projects/CSC249ADOA01_CNDA/brettin/Benchmarks/Pilot1/Uno"
LOCAL_PREFIX="."
# /dev/shm/Uno

# mkdir -p $LOCAL_PREFIX
export NUMEXPR_MAX_THREADS=256

# 749 unique drugs. 62 * 12 = 620 + 104 = 724
# OFFSET=144 (after running 12 nodes)
# OFFSET=0
# START_INDEX=$((PALS_RANKID + OFFSET))

echo "START_INDEX $START_INDEX"

ARGS=(
  --infile    $INFILE
  --outfile   $OUTFILE
  --partition $PARTITION
  --pals_rank $START_INDEX
)

set -x
python ./create_uno_h5.py ${ARGS[@]} |& tee create.log
