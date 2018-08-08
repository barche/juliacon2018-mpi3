using Distributed, MPI
mgr = MPI.start_main_loop(MPI.MPI_WINDOW_IO)

@everywhere begin
  const comm = MPI.COMM_WORLD
  const vec = fill(1,10)
  s = MPI.Reduce(sum(vec), +, 0, comm)
end

println("Sum is $s")

@everywhere println("Hello from $(MPI.Comm_rank(comm))")

MPI.stop_main_loop(mgr)