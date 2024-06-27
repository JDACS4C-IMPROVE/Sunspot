#!/bin/bash
set -eu

DATA_FILE=$1

# CANDLE HyperParameters
HP=( --ep 50
     --es True
     --config_file $PWD/uno_auc_model.txt
     --ckpt_restart_mode off
     --logfile python.log
     --use_exported_data $DATA_FILE
     --save_path=save
     --experiment_id=000
     --run_id=000
     --save_weights save/model.h5
   )

set -x
python uno_baseline_keras2.py ${HP[@]} |& tee log.txt
