#!/bin/zsh
set -eu

# EXTRACT PREDICTEDS ZSH
# Extract predicted.tsv files from directory of *.tar.gz
# chdir into the correct parent directory, then run this script

renice --priority 19 ${$}

TGZS=( **/*.tar.gz )
print "TOTAL: ${#TGZS}"

COUNT=1
for TGZ in ${TGZS}
do
  printf "%3i %s\n" ${COUNT} ${TGZ}
  DIR=${TGZ:h}
  # print $DIR
  tar --wildcards -C ${DIR} -xf ${TGZ} "*predicted.tsv"
  TSVS=( $( find ${DIR} -name predicted.tsv ) )
  print "EXTRACTED: ${#TSVS}"
done
