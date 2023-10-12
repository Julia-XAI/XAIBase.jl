"""
Return type of analyzers when calling [`analyze`](@ref).

## Fields
* `val`: numerical output of the analyzer, e.g. an attribution or gradient
* `output`: model output for the given analyzer input
* `neuron_selection`: neuron index used for the explanation
* `analyzer`: symbol corresponding the used analyzer, e.g. `:LRP` or `:Gradient`
* `extras`: optional named tuple that can be used by analyzers
    to return additional information.
"""
struct Explanation{V,O,I,E<:Union{Nothing,NamedTuple}}
    val::V
    output::O
    neuron_selection::I
    analyzer::Symbol
    extras::E
end
Explanation(val, output, ns, analyzer) = Explanation(val, output, ns, analyzer, nothing)
