# Send-receive example
using MPI

MPI.Init()

const comm = MPI.COMM_WORLD
const rank = MPI.Comm_rank(comm)
const tag = 0

if rank == 0
  msg = unsafe_wrap(Vector{UInt8},"Hi 1!")
  println("Sending message from rank 0 to rank 1")
  MPI.Send(msg, 1, tag, comm)
elseif rank == 1
  rec_buf = fill(UInt8('a'), 10)
  MPI.Recv!(rec_buf, 0, tag, comm)
  println("Received message $(String(rec_buf)) from rank 0")
end

println("Rank $rank is finalizing.")
MPI.Finalize()
