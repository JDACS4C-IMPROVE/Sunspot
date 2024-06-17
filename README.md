# Sunspot

## Installation

. Download Miniconda
. bash -b -p PREFIX Miniconda...sh
. Activate the Miniconda in PREFIX
. conda install pandas
. pip install tensorflow
. Clone candle_lib: git@github.com:ECP-CANDLE/candle_lib.git
. git checkout issue-38  # Fix for modern TensorFlow
. pip install /path/to/candle_lib

## Normal Uno usage

. Clone git@github.com:ECP-CANDLE/Benchmarks.git
. git checkout develop
. cd Pilot1/Uno
. python uno_baseline_keras2.py
