# Various heap implementation

###########################################################
#
#   Heap interface specification
#
#   Each heap is associated with a handle type (H), and
#   a value type v.
#
#   Here, the value type must be comparable, and a handle
#   is an object through which one can refer to a specific
#   node of the heap and thus update its value.
#
#   Each heap type must implement all of the following
#   functions. Here, let h be a heap, i be a handle,
#   v be a value and s be a size.
#
#   - length(h)           returns the number of elements
#
#   - isempty(h)          returns whether the heap is
#                         empty
#
#   - push!(h, v)         add a value to the heap
#
#   - sizehint!(h, s)     set size hint to a heap
#
#   - top(h)              return the top value of a heap
#
#   - pop!(h)             removes the top value, and
#                         returns it
#
#  For mutable heaps, it should also support
#
#   - push!(h, v)         adds a value to the heap and
#                         returns a handle to v
#
#   - update!(h, i, v)    updates the value of an element
#                         (referred to by the handle i)
#
#   - delete!(h, i)      deletes the node with
#                         handle i from the heap
#
#   - top_with_handle(h)  return the top value of a heap
#                         and its handle
#
#
###########################################################

# HT: handle type
# VT: value type

abstract type AbstractHeap{VT} end

abstract type AbstractMutableHeap{VT,HT} <: AbstractHeap{VT} end

abstract type AbstractMinMaxHeap{VT} <: AbstractHeap{VT} end

# heap implementations

include("heaps/binary_heap.jl")
include("heaps/mutable_binary_heap.jl")
include("heaps/minmax_heap.jl")

# generic functions

Base.eltype(::Type{<:AbstractHeap{T}}) where T = T

#=
Note that extract_all and extract_all_rev are slower than
sorting the array of values in-place.
Leaving these function here for use in testing.
=#

function extract_all!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(undef, n)
    for i = 1 : n
        r[i] = pop!(h)
    end
    r
end

function extract_all_rev!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(undef, n)
    for i = 1 : n
        r[n + 1 - i] = pop!(h)
    end
    r
end

# Array functions using heaps

function nextreme(ord::Base.Ordering, n::Int, arr::AbstractVector{T}) where T
    if n <= 0
        return T[] # sort(arr)[1:n] returns [] for n <= 0
    elseif n >= length(arr)
        return sort(arr, order = Base.ReverseOrdering(ord))
    end

    buffer = heapify(arr[1:n], ord)

    for i = n + 1 : length(arr)
        @inbounds xi = arr[i]
        if Base.lt(ord, buffer[1], xi)
            buffer[1] = xi
            percolate_down!(buffer, 1, ord)
        end
    end

    return sort!(buffer, order = Base.ReverseOrdering(ord))
end

"""
    nlargest(n, arr)

Return the `n` largest elements of the array `arr`.

Equivalent to `sort(arr, lt = >)[1:min(n, end)]`
"""
function nlargest(n::Int, arr::AbstractVector)
    return nextreme(FasterForward(), n, arr)
end

"""
    nsmallest(n, arr)

Return the `n` smallest elements of the array `arr`.

Equivalent to `sort(arr, lt = <)[1:min(n, end)]`
"""
function nsmallest(n::Int, arr::AbstractVector)
    return nextreme(FasterReverse(), n, arr)
end
