"""
Return type of analyzers when calling [`analyze`](@ref).

## Fields
* `val`: numerical output of the analyzer, e.g. an attribution or gradient
* `output`: model output for the given analyzer input
* `output_selection`: index of the output used for the explanation
* `analyzer`: symbol corresponding the used analyzer, e.g. `:Gradient` or `:LRP`
* `extras`: optional named tuple that can be used by analyzers
    to return additional information.
"""
struct Explanation{V,O,S,E<:Union{Nothing,NamedTuple}}
    val::V
    output::O
    output_selection::S
    analyzer::Symbol
    extras::E
end
Explanation(val, output, sel, analyzer) = Explanation(val, output, sel, analyzer, nothing)
