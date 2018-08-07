# Allreduce example
using MPI

MPI.Init()

const comm = MPI.COMM_WORLD
const rank = MPI.Comm_rank(comm)

vec = fill(1,10)
s = MPI.Allreduce(sum(vec), +, comm)
println("Sum on rank $rank: $(repr(s))")

MPI.Finalize()
