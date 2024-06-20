
echo IN BASH: PALS_RANKID=$PALS_RANKID $( hostname )


USE_MPI=0

if (( USE_MPI ))
then
  enable -f mpibash.so mpi_init
  echo INIT
  mpi_init

  echo RANK
  mpi_comm_rank rank
  echo RANK is $rank

  echo BARRIER
  mpi_barrier
fi

if (( PALS_RANKID < 14 ))
then
  sleep 1
  printf "EXIT on %3i %s\n" $PALS_RANKID $( hostname )
  exit 0
fi

sleep 1

if (( USE_MPI ))
then
  echo FINALIZE
  mpi_finalize
  echo DONE
fi
