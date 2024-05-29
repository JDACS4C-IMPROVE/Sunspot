#!/bin/bash

echo "PBS_JOBID $PBS_JOBID"

# function to copy data when done
copy_data() {
	# Copy only python.log and predicted.tsv back to submit host
        cd $LOCAL_PREFIX/save/
        
	# copy 
	# find . -name python.log -exec tar -rf $LOCAL_PREFIX/save/$PBS_JOBID.tar {} \;
        # find . -name predicted.tsv -exec tar -rf $LOCAL_PREFIX/save/$PBS_JOBID.tar {} \;
        # find . -name *.model.h5 -exec tar -rf $LOCAL_PREFIX/save/$PBS_JOBID.tar {} \;

	# copy everything.
	find . -exec tar -rf $LOCAL_PREFIX/save/$PBS_JOBID.tar {} \;

        gzip $LOCAL_PREFIX/save/$PBS_JOBID.tar

        # Common to both
        mkdir -p $GLOBAL_PREFIX/save/$PBS_JOBID/$(hostname)/
        cp $LOCAL_PREFIX/save/$PBS_JOBID.tar.gz $GLOBAL_PREFIX/save/$PBS_JOBID/$(hostname)/
        echo "$(date) DONE_COPYING_RESULTS_uno_baseline_keras2.py from $(hostname)"

}
# Set trap to call copy_data when receiving SIGTERM
#trap 'copy_data' SIGTERM


if [[ -v MPI_LOCALRANKID ]]; then
  _MPI_RANKID=$MPI_LOCALRANKID
elif [[ -v PALS_LOCAL_RANKID ]]; then
  _MPI_RANKID=$PALS_LOCAL_RANKID
else
  echo "could not get RANK"
  exit
fi

GLOBAL_PREFIX=${GLOBAL_PREFIX:-"/home/brettin/CSC249ADOA01_CNDA/brettin/Benchmarks/Pilot1/Uno"}
UNO_DIR=${UNO_DIR:-"/home/brettin/CSC249ADOA01_CNDA/brettin/Benchmarks/Pilot1/Uno"}
LOCAL_PREFIX="/dev/shm/Uno"
EXPORTED_DATA_DIR=${EXPORTED_DATA_DIR:-"/home/brettin/CSC249ADOA01_CNDA/brettin/Benchmarks/Pilot1/Uno"}
EXPORTED_DATA_FILE="$(hostname).${PALS_RANKID}.merged.landmark.h5"

mkdir -p $LOCAL_PREFIX

if [[ "$_MPI_RANKID" == 0 ]] ; then
	cp $0 ${LOCAL_PREFIX}/
fi

export CANDLE_DATA_DIR=$LOCAL_PREFIX

# aurora has 12 logical GPUs
num_gpu=$(/usr/bin/udevadm info /sys/module/i915/drivers/pci:i915/* |& grep -v Unknown | grep -c "P: /devices")
num_tile=2
gpu_id=$(((_MPI_RANKID / num_tile) % num_gpu))
tile_id=$((_MPI_RANKID % num_tile))

unset EnableWalkerPartition
export ZE_ENABLE_PCI_ID_DEVICE_ORDER=1
export ZE_AFFINITY_MASK=$gpu_id.$tile_id
export ZEX_NUMBER_OF_CCS=0:1,1:1,2:1,3:1,4:1,5:1
export NUMEXPR_MAX_THREADS=256

mkdir -p $LOCAL_PREFIX/save/$PBS_JOBID/$PALS_RANKID

echo "$(date) CALLING_uno_baseline_keras2.py"
python $UNO_DIR/uno_baseline_keras2.py \
        --ep 50  \
	--es True \
	--config_file $GLOBAL_PREFIX/uno_auc_model.txt \
	--ckpt_restart_mode off \
	--ckpt_directory $LOCAL_PREFIX/save/$PBS_JOBID/$PALS_RANKID      \
	--ckpt_save_interval 0                                              \
	--logfile $LOCAL_PREFIX/save/$PBS_JOBID/$PALS_RANKID/python.log  \
	--use_exported_data $LOCAL_PREFIX/$EXPORTED_DATA_FILE               \
	--save_path=$LOCAL_PREFIX/save/$PBS_JOBID/$PALS_RANKID                      \
	--experiment_id=$PBS_JOBID --run_id=$PALS_RANKID                            \
	--save_weights $LOCAL_PREFIX/save/$PBS_JOBID/$PALS_RANKID/$ZE_AFFINITY_MASK.model.h5  \
	> $LOCAL_PREFIX/save/$PBS_JOBID/$PALS_RANKID/log.txt 2>&1
echo "$(date) DONE_CALLING_uno_baseline_keras2.py"


# wait for all ranks on this node to finish
echo "calling copy on rank $_MPI_RANKID"
if [[ "$_MPI_RANKID" == 0 ]] ; then
	echo "in copy loop on rank $_MPI_RANKID"
	echo "$(date) START_COPYING_RESULTS_uno_baseline_keras2.py from $(hostname)"
	# fcount=$(find $LOCAL_PREFIX/save/ -name "*.h5" | wc -l)
	fcount=$(find $LOCAL_PREFIX/save/ -name "predicted.tsv" | wc -l)
	while [[ $fcount != "12" ]] ; do
		sleep 3
		#fcount=$(find $LOCAL_PREFIX/save/ -name "*.h5" | wc -l)
		fcount=$(find $LOCAL_PREFIX/save/ -name "predicted.tsv" | wc -l)
		echo "in wait loop on $(hostname) local_rank $_MPI_RANKID"
		echo "found ${fcount} predicted.tsv files"
	done
	echo "out of wait loop on $(hostname) local_rank $_MPI_RANKID"
	copy_data
	# Copy everyting back to submit host
	# tar -czf $LOCAL_PREFIX/save/$PBS_JOBID.tar.gz $LOCAL_PREFIX/save/$PBS_JOBID
		
	# Copy only python.log and predicted.tsv back to submit host
	# cd $LOCAL_PREFIX/save/
	# find . -name python.log -exec tar -rf $LOCAL_PREFIX/save/$PBS_JOBID.tar {} \;
	# find . -name predicted.tsv -exec tar -rf $LOCAL_PREFIX/save/$PBS_JOBID.tar {} \;
	# #find . -name *.model.h5 -exec tar -rf $LOCAL_PREFIX/save/$PBS_JOBID.tar {} \;

	# gzip $LOCAL_PREFIX/save/$PBS_JOBID.tar

	# Common to both
	# mkdir -p $GLOBAL_PREFIX/save/$PBS_JOBID/$(hostname)/
	# cp $LOCAL_PREFIX/save/$PBS_JOBID.tar.gz $GLOBAL_PREFIX/save/$PBS_JOBID/$(hostname)/
	# echo "$(date) DONE_COPYING_RESULTS_uno_baseline_keras2.py from $(hostname)"
fi
