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
TOTAL=${#TGZS}
print "TOTAL: ${TOTAL}"

renice --priority 19 ${$}

T=$( mktemp --tmpdir=/tmp/$USER )

COUNT=0
for TGZ in ${TGZS}
do
  (( ++ COUNT ))
  printf "COUNT: %5i / %i : %s\n" ${COUNT} ${TOTAL} ${TGZ}
  # Get dirname:
  DIR=${TGZ:h}
  if [[ -d ${OUTPUT}/${DIR} ]]
  then
    print "EXISTS:  ${OUTPUT}/${DIR}"
    continue
  fi
  print "DIR:     ${DIR}"
  gunzip --stdout ${TGZ} > ${T}
  print "CHECK..."
  if ! tar --wildcards -tf ${T} "*predicted.tsv" > /dev/null
  then
    print "No predicted.tsv: SKIPPING"
    continue
  fi
  mkdir -pv ${OUTPUT}/${DIR}
  # Can use --keep-old-files to abort on file overwrites
  #     but existing TGZs contain multiples
  tar --wildcards -C ${OUTPUT}/${DIR} \
      -v -xf ${T} "*predicted.tsv" "*python.log"
  TSVS=( $( find ${OUTPUT}/${DIR} -name predicted.tsv ) )
  print "EXTRACTED TSVs: ${#TSVS}"
  print
  # if (( COUNT == 5 )) exit
done

rm ${T}
