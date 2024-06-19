#!/bin/bash
#PBS -A candle_aesp_CNDA
#PBS -l walltime=2:00:00
#PBS -l select=12
#PBS -l place=scatter
#PBS -q workq
#PBS -W tolerate_node_failures=all

# Set data partition partition type here
# PARTITION="by_drug"

echo "$(date) PBS_JOBID $PBS_JOBID"
export NN=$(cat $PBS_NODEFILE | wc -l)
export PPN=12    # 12

echo "$(date) NUM NODES $NN"
echo "$(date) PPN $PPN"

# DISTRIBUTING FRAMEWORKS ENVIRONMENT TO LOCAL COMPUTE NODES [Feb 16, 2024]
echo "$(date) START_SETUP_env"
mpiexec -np $NN -ppn 1 --pmi=pmix tar zxf /lus/gila/projects/CSC249ADOA01_CNDA/brettin/local-frameworks-23.266.2-20240131a.tar.gz -C /tmp


# Activate the runtime environment
export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128
export https_proxy=http://proxy.alcf.anl.gov:3128
git config --global http.proxy http://proxy.alcf.anl.gov:3128
source /tmp/local-frameworks/source_env.sh


# Set CANDLE_DATA_DIR
cd ~/CSC249ADOA01_CNDA/brettin/Benchmarks/Pilot1/Uno
export CANDLE_DATA_DIR=.


# Distribute the df
LOCAL_PREFIX=/dev/shm
INFILE="merged.landmark.h5"
echo "$(date) START_distribute_df INFILE=${INFILE}"
mpiexec -np $NN -ppn 1 --pmi=pmix cp ${INFILE} ${LOCAL_PREFIX}/$(basename ${INFILE})


# Create the splits
NP=$(( NN * PPN ))
PARTITION="by_drug"
echo "$(date) START_create_uno_h5.sh $LOCAL_PREFIX/$INFILE  $PARTITION"
mpiexec -np $NP -ppn $PPN --pmi=pmix ./create_uno_h5.sh $LOCAL_PREFIX/$INFILE $PARTITION > ${PBS_JOBID}.create_uno_h5.log 2>&1


# Train PPN models using NN nodes
NP=$(( NN * PPN ))
echo "$(date) LAUNCH_sunspot_uno_baseline_keras2 NP=${NP}"
mpiexec -ppn ${PPN} --np ${NP} ./sunspot_uno_baseline_keras2.sh > ${PBS_JOBID}.sunspot_uno_baseline_keras2.log

# mpiexec -ppn 12 --np $NP -d 16 ./sunspot_uno_baseline_keras2.sh > ${PBS_JOBID}.sunspot_uno_baseline_keras2.log
# Train 12000 models on 1000 nodes
# mpiexec -ppn 12 --np 12000 -d 16 ./sunspot_uno_baseline_keras2.sh > 1000node50epochs.log.distributed.pythonlog  2>&1

echo "$(date) DONE_LAUNCH_sunspot_uno_baseline_keras2"
