# Binary heap (non-mutable)

include("arrays_as_heaps.jl")

#################################################
#
#   heap type and constructors
#
#################################################

#=
These structs may be substituted by Base.Forward and Base.Reverse,
but float comparison will be 2x slower to preserve ordering with NAN values.
=#
struct FasterForward <: Base.Ordering end
struct FasterReverse <: Base.Ordering end
Base.lt(o::FasterForward, a, b) = a < b
Base.lt(o::FasterReverse, a, b) = a > b

mutable struct BinaryHeap{T, O <: Base.Ordering} <: AbstractHeap{T}
    valtree::Vector{T}
    ordering::O

    # min heap by default
    function BinaryHeap(::Type{T}, ordering::O = FasterForward()) where {T,O}
        new{T,O}(Vector{T}(), ordering)
    end

    function BinaryHeap(xs::AbstractVector{T}, ordering::O = FasterForward()) where {T,O}
        valtree = heapify(xs, ordering)
        new{T,O}(valtree, ordering)
    end
end

BinaryMinHeap(xs::AbstractVector) = BinaryHeap(xs, FasterForward())
BinaryMaxHeap(xs::AbstractVector) = BinaryHeap(xs, FasterReverse())
BinaryMinHeap(::Type{T}) where T = BinaryHeap(T, FasterForward())
BinaryMaxHeap(::Type{T}) where T = BinaryHeap(T, FasterReverse())


#################################################
#
#   interfaces
#
#################################################

# Todo document and reorder these

length(h::BinaryHeap) = length(h.valtree)

isempty(h::BinaryHeap) = isempty(h.valtree)

function push!(h::BinaryHeap, v)
    heappush!(h.valtree, v, h.ordering)
    h
end

function sizehint!(h::BinaryHeap, s::Integer)
    sizehint!(h.valtree, s)
    return h
end

"""
    top(h::BinaryHeap)

Returns the element at the top of the heap `h`.
"""
@inline top(h::BinaryHeap) = h.valtree[1]

"""
    pop(h::BinaryHeap)

Removes and returns the element at the top of the heap `h`.
"""
pop!(h::BinaryHeap) = heappop!(h.valtree, h.ordering)
