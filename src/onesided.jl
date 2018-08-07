using MPI

MPI.Init()
comm = MPI.COMM_WORLD
const rank = MPI.Comm_rank(comm)
const N = MPI.Comm_size(comm)
const dest = 0
const no_assert = 0

# set up an array of length N on each process and mark it shared
shared = zeros(N)
win = MPI.Win()
MPI.Win_create(shared, MPI.INFO_NULL, comm, win)

# Every rank writes to the array held by rank 0 (dest) at its rank position
offset = rank
nb_elms = 1
MPI.Win_lock(MPI.LOCK_EXCLUSIVE, dest, no_assert, win)
MPI.Put([Float64(rank)], nb_elms, dest, offset, win)
MPI.Win_unlock(dest, win)

# Wait for all ranks to get here
MPI.Barrier(comm)

if rank == dest
  MPI.Win_lock(MPI.LOCK_SHARED, dest, no_assert, win)
  println("My partners sent me this: ", shared')
  MPI.Win_unlock(dest, win)
end

MPI.Finalize()