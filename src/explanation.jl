"""
    Explanation(val, input, output, output_selection, pooling; extras)

Return type of analyzers when calling [`analyze`](@ref).

## Fields
* `val`: numerical output of the analyzer, e.g. an attribution or gradient
* `input`: input for the given analyzer
* `output`: model output for the given analyzer input
* `output_selection`: index of the output used for the explanation
* `pooling`: an [`AbstractPooling`](@ref) function that reduces `val` over its feature
    dimension when projecting the explanation onto a human-interpretable space,
    e.g. for visualization. Downstream packages such as VisionHeatmaps.jl call it as
    `pooling(val, dim)`, choosing the reduced dimension `dim` themselves.
    Defaults to [`NormPooling`](@ref).
* `extras`: optional named tuple that can be used by analyzers
    to return additional information. Keyword argument, defaults to `nothing`.

`pooling` is an optional positional argument, defaulting to [`NormPooling`](@ref).
"""
struct Explanation{V, I, O, S, P <: AbstractPooling, E <: Union{Nothing, NamedTuple}}
    val::V
    input::I
    output::O
    output_selection::S
    pooling::P
    extras::E
end
function Explanation(
        val, input, output, output_selection,
        pooling::AbstractPooling = NormPooling();
        extras::Union{Nothing, NamedTuple} = nothing,
    )
    return Explanation(val, input, output, output_selection, pooling, extras)
end
