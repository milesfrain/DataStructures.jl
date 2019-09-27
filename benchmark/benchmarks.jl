using Pkg
tempdir = mktempdir()
Pkg.activate(tempdir)
Pkg.develop(PackageSpec(path=joinpath(@__DIR__, "..")))
Pkg.add(["BenchmarkTools", "PkgBenchmark", "Random"])
Pkg.resolve()

using DataStructures
using BenchmarkTools
using Random

#include("mystruct.jl")

function push_heap(h::AbstractHeap, xs::Vector)
    n = length(xs)

    for i = 1 : n
        push!(h, xs[i])
    end
end

function pop_heap(h::AbstractHeap)
    n = length(h)

    for i = 1 : n
        pop!(h)
    end
end

const SUITE = BenchmarkGroup()

heaptypes = [BinaryHeap, MutableBinaryHeap]
aexps = [1,3]
datatypes = [Int, Float64] #, MyStruct]
baseorderings = Dict(
    "Min" => DataStructures.LessThan,
    #"Max" => Base.Reverse,
    )
floatorderings = Dict(
    #"FastMin" => DataStructures.FasterForward(),
    #"FastMax" => DataStructures.FasterReverse(),
    )
structorderings = Dict(
    #"StructMin" => mystruct_ordering,
    #"StructMax" => Base.ReverseOrdering(mystruct_ordering),
    )

for heap in heaptypes
    for aexp in aexps
        for dt in datatypes
            Random.seed!(0)
            a = rand(dt, 10^aexp)

            orderings = baseorderings
            if dt == Float64
                orderings = merge(floatorderings, baseorderings)
            #elseif dt == MyStruct
            #    orderings = merge(structorderings, baseorderings)
            end

            for (ord_str, ord) in orderings
                prepath = [string(heap)]
                postpath = [string(dt), "10^"*string(aexp), ord_str]
                SUITE[vcat(["heap"], prepath, ["make"], postpath)] =
                    @benchmarkable $(heap){$dt,$ord}($a)
                SUITE[vcat(["heap"], prepath, ["push"], postpath)] =
                    @benchmarkable push_heap(h, $a) setup=(h=$(heap){$dt,$ord}())
                SUITE[vcat(["heap"], prepath, ["pop"], postpath)] =
                    @benchmarkable pop_heap(h) setup=(h=$(heap){$dt,$ord}($a))
            end
        end
    end
end

# Quick check to ensure no Float regressions with Min/Max convenience functions
# These don't fit in well with the above loop, since ordering is hardcoded.
heapalias = Dict(
    "BinaryMinHeap" => BinaryMinHeap,
    "BinaryMaxHeap" => BinaryMaxHeap,
    "BinaryMinMaxHeap" => BinaryMinMaxHeap, # <- no alias issue
)
for (heapname, heap) in heapalias
    for aexp in aexps
        for dt in [Float64]
            Random.seed!(0)
            a = rand(dt, 10^aexp)
            prepath = [heapname]
            postpath = [string(dt), "10^"*string(aexp)]
            SUITE[vcat(["heap"], prepath, ["make"], postpath)] =
                @benchmarkable $(heap)($a)
            SUITE[vcat(["heap"], prepath, ["push"], postpath)] =
                @benchmarkable push_heap(h, $a) setup=(h=$(heap){$dt}())
            SUITE[vcat(["heap"], prepath, ["pop"], postpath)] =
                @benchmarkable pop_heap(h) setup=(h=$(heap)($a))
        end
    end
end

for func in [nlargest, nsmallest]
    for aexp in [4]
        Random.seed!(0);
        a = rand(10^aexp);
        for nexp in [2]
            n = 10^nexp
            SUITE[["heap", string(func), "a=rand(10^"*string(aexp)*")", "n=10^"*string(nexp)]] =
                @benchmarkable $(func)($n, $a)
        end
    end
end
