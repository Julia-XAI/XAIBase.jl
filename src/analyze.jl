"""
    analyze(input, method)
    analyze(input, method, output_selection)

Apply the analyzer `method` for the given input, returning an [`Explanation`](@ref).
If `output_selection` is specified, the explanation will be calculated for that output.
Otherwise, the output with the highest activation is automatically chosen.

See also [`Explanation`](@ref).
"""
function analyze(
    input, method::AbstractXAIMethod, output_selector::AbstractOutputSelector; kwargs...
)
    return call_analyzer(input, method, output_selector; kwargs...)
end
function analyze(
    input,
    method::AbstractXAIMethod,
    output_selection::Union{Integer,Tuple{<:Integer}};
    kwargs...,
)
    return call_analyzer(input, method, IndexSelector(output_selection); kwargs...)
end

function analyze(input, method::AbstractXAIMethod; kwargs...)
    return call_analyzer(input, method, MaxActivationSelector(); kwargs...)
end

# Direct calls to analyzer
function (method::AbstractXAIMethod)(input; kwargs...)
    analyze(input, method, MaxActivationSelector(); kwargs...)
end
function (method::AbstractXAIMethod)(input, output_selector; kwargs...)
    analyze(input, method, output_selector; kwargs...)
end

# Throw NotImplementedError as a fallback
function call_analyzer(
    input, method::AbstractXAIMethod, output_selector::AbstractOutputSelector; kwargs...
)
    return throw(
        NotImplementedError(
            method,
            "call_analyzer(input, method::T, output_selector::AbstractOutputSelector; kwargs...)",
        ),
    )
end
