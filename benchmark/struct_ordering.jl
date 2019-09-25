using DataStructures

struct FieldOrder
    sym::Symbol
    ord::Base.Ordering
end

struct StructOrdering <: Base.Ordering
    field_orderings::AbstractVector{FieldOrder}
end

function Base.lt(struct_ordering::StructOrdering, a, b)
    for field_ordering in struct_ordering.field_orderings
        sym = field_ordering.sym
        ord = field_ordering.ord
        va = getproperty(a, sym)
        vb = getproperty(b, sym)
        Base.lt(ord, va, vb) && return true
        Base.lt(ord, vb, va) && return false
    end
    false # a and b are equal
end
