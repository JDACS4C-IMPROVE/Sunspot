#!/bin/bash

INFILE=$1    # INFILE="/dev/shm/merged.landmark.h5"
PARTITION=$2

OUTFILE=$(hostname).${PALS_RANKID}.$(basename ${INFILE})
GLOBAL_PREFIX="/lus/gila/projects/CSC249ADOA01_CNDA/brettin/Benchmarks/Pilot1/Uno"
LOCAL_PREFIX="/dev/shm/Uno"

mkdir -p $LOCAL_PREFIX
export NUMEXPR_MAX_THREADS=256

# 749 unique drugs. 62 * 12 = 620 + 104 = 724
# OFFSET=144 (after running 12 nodes)
OFFSET=0
START_INDEX=$((PALS_RANKID + OFFSET))

echo "$(date) START_INDEX ${START_INDEX}"
echo "python ./create_uno_h5.py --infile $INFILE --outfile $LOCAL_PREFIX/$OUTFILE --partition $PARTITION --pals_rank ${START_INDEX} > ${GLOBAL_PREFIX}/${OUTFILE}.log"
python ./create_uno_h5.py --infile $INFILE --outfile $LOCAL_PREFIX/$OUTFILE --partition $PARTITION --pals_rank ${START_INDEX}
# python ./create_uno_h5.py --infile $INFILE --outfile $LOCAL_PREFIX/$OUTFILE --partition $PARTITION --pals_rank ${START_INDEX} > ${GLOBAL_PREFIX}/${PBS_JOBID}.${OUTFILE}.log
