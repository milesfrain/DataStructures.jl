include("struct_ordering.jl")

struct MyStruct
    a::Int64
    b::Int64
    c::Int64
end

#=
The StructOrdering type allows a prioritized list of field comparisons
In this case, order by field :a in descending order, if tied, arrange by :b in
descending order, etc.
=#
mystruct_ordering = StructOrdering([
    FieldOrder(:a, Base.Reverse),
    FieldOrder(:b, Base.Forward),
    FieldOrder(:c, Base.Reverse)
    ])

#=
You may also define a Base.isless function for structs,
which allows use in heaps without a custom ordering.
But isless is not as easy as orderings to customize dynamically.
The following example is equivalent to the above ordering.
=#
function Base.isless(a::MyStruct, b::MyStruct)
    a.a > b.a && return true
    a.a < b.a && return false

    a.b < b.b && return true
    a.b > b.b && return false

    a.c > b.c && return true
    a.c < b.c && return false

    return false
end

#= Here is another arbitrary example, which is different than mystruct_ordering
function Base.isless(a::MyStruct, b::MyStruct)
    a.a + a.b + a.c < b.a + b.b + b.c
end
=#

# This is necessary for rand(MyStruct, 42)
function Random.rand(rng::AbstractRNG, ::Random.SamplerType{MyStruct})
    MyStruct(
        rand(rng, Int),
        rand(rng, Int),
        rand(rng, Int),
    )
end
