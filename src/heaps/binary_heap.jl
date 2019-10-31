# Binary heap (non-mutable)

include("arrays_as_heaps.jl")

#################################################
#
#   heap type and constructors
#
#################################################

#=
FasterForward enables 2x faster float comparison versus Base.ForwardOrdering,
but ordering is undefined if the data contains NaN values.
Enable this higher-performance option by calling the BinaryHeap
constructor instead of the BinaryMinHeap helper constructor.
The same is true for FasterReverse and BinaryMaxHeap.
=#
struct FasterForward <: Base.Ordering end
struct FasterReverse <: Base.Ordering end
Base.lt(o::FasterForward, a, b) = a < b
Base.lt(o::FasterReverse, a, b) = a > b

mutable struct BinaryHeap{T, O <: Base.Ordering} <: AbstractHeap{T}
    ordering::O
    valtree::Vector{T}

    function BinaryHeap{T, O}() where {T,O}
        new{T,O}(O(), Vector{T}())
    end

    function BinaryHeap{T, O}(xs::AbstractVector{T}) where {T,O}
        ordering = O()
        valtree = heapify(xs, ordering)
        new{T,O}(ordering, valtree)
    end
end

const BinaryMinHeap{T} = BinaryHeap{T, Base.ForwardOrdering}
const BinaryMaxHeap{T} = BinaryHeap{T, Base.ReverseOrdering}
BinaryMinHeap(xs::AbstractVector{T}) where T = BinaryMinHeap{T}(xs)
BinaryMaxHeap(xs::AbstractVector{T}) where T = BinaryMaxHeap{T}(xs)

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
