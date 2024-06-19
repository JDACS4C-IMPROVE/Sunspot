
echo IN BASH

enable -f mpibash.so mpi_init
echo INIT
mpi_init

echo RANK
mpi_comm_rank rank
echo RANK is $rank

echo BARRIER
mpi_barrier

echo FINALIZE
mpi_finalize
echo DONE
