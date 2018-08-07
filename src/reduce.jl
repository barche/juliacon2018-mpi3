# Reduce example
using MPI

MPI.Init()

const comm = MPI.COMM_WORLD
const rank = MPI.Comm_rank(comm)
const root = 0

vec = fill(1,10)
s = MPI.Reduce(sum(vec), +, root, comm)
println("Sum on rank $rank: $(repr(s))")

MPI.Finalize()
