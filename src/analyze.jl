
const BATCHDIM_MISSING = ArgumentError(
    """The input is a 1D vector and therefore missing the required batch dimension.
    Call `analyze` with the keyword argument `add_batch_dim=true`."""
)

"""
    analyze(input, method)
    analyze(input, method, neuron_selection)

Apply the analyzer `method` for the given input, returning an [`Explanation`](@ref).
If `neuron_selection` is specified, the explanation will be calculated for that neuron.
Otherwise, the output neuron with the highest activation is automatically chosen.

See also [`Explanation`](@ref) and [`heatmap`](@ref).

## Keyword arguments
- `add_batch_dim`: add batch dimension to the input without allocating. Default is `false`.
"""
function analyze(
    input::AbstractArray{<:Real},
    method::AbstractXAIMethod,
    neuron_selection::Union{Integer,Tuple{<:Integer}};
    kwargs...,
)
    return _analyze(input, method, IndexSelector(neuron_selection); kwargs...)
end

function analyze(input::AbstractArray{<:Real}, method::AbstractXAIMethod; kwargs...)
    return _analyze(input, method, MaxActivationSelector(); kwargs...)
end

function (method::AbstractXAIMethod)(
    input::AbstractArray{<:Real},
    neuron_selection::Union{Integer,Tuple{<:Integer}};
    kwargs...,
)
    return _analyze(input, method, IndexSelector(neuron_selection); kwargs...)
end
function (method::AbstractXAIMethod)(input::AbstractArray{<:Real}; kwargs...)
    return _analyze(input, method, MaxActivationSelector(); kwargs...)
end

# lower-level call to method
function _analyze(
    input::AbstractArray{T,N},
    method::AbstractXAIMethod,
    sel::AbstractNeuronSelector;
    add_batch_dim::Bool=false,
    kwargs...,
) where {T<:Real,N}
    if add_batch_dim
        return method(batch_dim_view(input), sel; kwargs...)
    end
    N < 2 && throw(BATCHDIM_MISSING)
    return method(input, sel; kwargs...)
end
