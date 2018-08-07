module SimpleMPI

using MPI

export SimpleMPIVector

struct SimpleMPIVector{T} <: AbstractVector{T}
  localarray::Vector{T}
  comm::MPI.Comm
  win::MPI.Win
  myrank::Int

  function SimpleMPIVector{T}(comm::MPI.Comm, len) where {T}
    locarr = Vector{T}(undef, len)
    win = MPI.Win()
    MPI.Win_create(locarr, MPI.INFO_NULL, comm, win)
    return new{T}(locarr, comm, win, MPI.Comm_rank(comm))
  end
end

Base.IndexStyle(::Type{SimpleMPIVector{T}}) where {T} = IndexLinear()
Base.size(v::SimpleMPIVector) = size(v.localarray) .* MPI.Comm_size(v.comm)

function Base.getindex(v::SimpleMPIVector{T}, i::Int) where {T}
  loclen = length(v.localarray)
  target_rank = (i-1) ÷ loclen
  local_index = (i-1) % loclen
  result = Ref{T}()
  MPI.Win_lock(MPI.LOCK_SHARED, target_rank, 0, v.win)
  MPI.Get(result, 1, target_rank, local_index, v.win)
  MPI.Win_unlock(target_rank, v.win)
  return result[]
end

function Base.setindex!(v::SimpleMPIVector{T}, val, i::Int) where {T}
  loclen = length(v.localarray)
  target_rank = (i-1) ÷ loclen
  local_index = (i-1) % loclen
  MPI.Win_lock(MPI.LOCK_EXCLUSIVE, target_rank, 0, v.win)
  MPI.Put(Ref{T}(val), 1, target_rank, local_index, v.win)
  MPI.Win_unlock(target_rank, v.win)
end

end

using MPI
using .SimpleMPI

MPI.Init()
comm = MPI.COMM_WORLD
const rank = MPI.Comm_rank(comm)
const mylength = 4
const mystart = rank*mylength+1
const myend = mystart + mylength - 1

vec = SimpleMPIVector{Int}(comm, mylength)
rank == 0 && @show length(vec)

for i in mystart:myend
  vec[i] = rank
end

MPI.Barrier(comm)

rank == 0 && println("The global vector is ", vec')

MPI.Finalize()
