using MPI
MPI.Init()
comm = MPI.COMM_WORLD
const rank = MPI.Comm_rank(comm)

# winio receives data on all processes from anyone
const winio = WindowIO(comm)
# everyone can write to process 0
const writer = WindowWriter(winio, 0)

println(writer, "Hello from $rank")
flush(writer)

if rank == 0
  nb_received = 0
  while nb_received < MPI.Comm_size(comm)
    received = readline(winio)
    println("Received message: $received")
    global nb_received += 1
  end
end

MPI.Finalize()
