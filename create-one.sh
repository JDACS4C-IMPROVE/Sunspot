#!/bin/bash

INFILE=$1
PARTITION="by_drug" # $2
START_INDEX=$2

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
}

set -x
python ./create_uno_h5.py ${ARGS[@]} 2>&1 | tee create.log
