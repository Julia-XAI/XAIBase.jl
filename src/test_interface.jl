"""
    test_interface(method, input; output_selection = 1)

Test that `method`, an [`AbstractXAIMethod`](@ref), 
correctly implements the XAIBase interface for the given `input`, returning `true` if it does.

The returned [`Attribution`](@ref) is checked by calling [`analyze`](@ref), asserting that

* `analyze` returns an [`Attribution`](@ref),
* the batch dimension (the last dimension) of `val`, `input` and `output` is consistent,
* `output_selection` is a `Vector{<:CartesianIndex}` with one entry per batch sample, and
* `pooling` is an [`AbstractPooling`](@ref).

Both the automatic output selection (`analyze(input, method)`)
and the explicit selection `analyze(input, method, output_selection)` are exercised.
`output_selection` is passed to an [`IndexSelector`](@ref) and defaults to `1`.

The first violated invariant throws an `InterfaceError` describing the problem.

```julia
using XAIBase, Test

@testset "XAIBase interface" begin
    @test XAIBase.test_interface(MyMethod(), rand(Float32, 32, 32, 3, 2))
end
```

$NOTE_OUTPUT_SELECTOR
"""
function test_interface(method::AbstractXAIMethod, input::AbstractArray; output_selection = 1)
    check(cond, msg) = cond || throw(InterfaceError(method, msg))
    batchsize = size(input)[end]

    # Both the automatic and the explicit output selection must return an `Attribution`
    check(
        analyze(input, method) isa Attribution,
        "`analyze(input, method)` must return an `Attribution`.",
    )
    attr = analyze(input, method, output_selection)
    check(
        attr isa Attribution,
        "`analyze(input, method, output_selection)` must return an `Attribution`.",
    )

    # `val`, `input` and `output` must carry the batch dimension as their last dimension
    check(
        attr.input isa AbstractArray && size(attr.input)[end] == batchsize,
        "`attr.input` must be an array whose last (batch) dimension matches the input's ($batchsize).",
    )
    check(
        attr.val isa AbstractArray && size(attr.val)[end] == batchsize,
        "`attr.val` must be an array whose last (batch) dimension is $batchsize.",
    )
    check(
        attr.output isa AbstractArray && size(attr.output)[end] == batchsize,
        "`attr.output` must be an array whose last (batch) dimension is $batchsize.",
    )

    # `output_selection` holds one `CartesianIndex` per batch sample
    check(
        attr.output_selection isa AbstractVector{<:CartesianIndex},
        "`attr.output_selection` must be a `Vector{<:CartesianIndex}`.",
    )
    check(
        length(attr.output_selection) == batchsize,
        "`attr.output_selection` must contain one index per batch sample ($batchsize).",
    )

    check(
        attr.pooling isa AbstractPooling,
        "`attr.pooling` must be an `AbstractPooling`.",
    )
    return true
end
