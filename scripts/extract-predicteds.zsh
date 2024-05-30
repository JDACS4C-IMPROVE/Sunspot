#!/bin/zsh
set -eu

# EXTRACT PREDICTEDS ZSH
# Extract predicted.tsv files from directory of *.tar.gz
# chdir into the correct parent directory, then run this script

if (( ${#*} != 1 ))
then
  print "Provide output directory!"
  return 1
fi

OUTPUT=$1

TGZS=( **/*.tar.gz )
print "TOTAL: ${#TGZS}"

renice --priority 19 ${$}

COUNT=1
for TGZ in ${TGZS}
do
  printf "%3i %s\n" ${COUNT} ${TGZ}
  DIR=${TGZ:h}
  # print $DIR
  if ! tar --wildcards -tf ${TGZ} "*predicted.tsv" > /dev/null
  then
    continue
  fi
  tar --wildcards -C ${OUTPUT} -xvf ${TGZ} "*predicted.tsv"
  TSVS=( $( find ${OUTPUT} -name predicted.tsv ) )
  print "EXTRACTED: ${#TSVS}"
done
