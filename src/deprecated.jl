function Explanation(val, output, output_selection, analyzer::Symbol)
    @warn "Creating an Explanation without a heatmap style is being deprecated. Defaulting to `heatmap=:attribution`."
    return Explanation(val, output, output_selection, analyzer, :attribution, nothing)
end
function Explanation(
    val, output, output_selection, analyzer::Symbol, extras::Union{Nothing,NamedTuple}
)
    @warn "Creating an Explanation without a heatmap style is being deprecated. Defaulting to `heatmap=:attribution`."
    return Explanation(val, output, output_selection, analyzer, :attribution, extras)
end
