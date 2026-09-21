"""
    Batch(A; dims = ndims(A))

Wrap an array `A` to mark it as a batch of samples along the batch dimension `dims`,
which defaults to the last dimension of `A`.
Unwrapped arrays are treated as single samples.

Downstream packages use `Batch` to distinguish transforms
that are applied to each sample individually (the default, see [`XAIBase.mapsamples`](@ref))
from batch-aware transforms like [`BatchedNormalization`](@ref).
"""
struct Batch{T <: AbstractArray}
    val::T
    dims::Int

    function Batch(val::T, dims::Integer) where {T <: AbstractArray}
        1 <= dims <= ndims(val) || throw(
            ArgumentError(
                "batch dimension $dims is out of range for a $(ndims(val))-dimensional array",
            ),
        )
        return new{T}(val, dims)
    end
end
Batch(val::AbstractArray; dims::Integer = ndims(val)) = Batch(val, dims)

Base.:(==)(a::Batch, b::Batch) = a.dims == b.dims && a.val == b.val

"""
    eachsample(batch)

Iterate over the samples in a [`XAIBase.Batch`](@ref), which are views into the wrapped array.
"""
eachsample(b::Batch) = eachslice(b.val; dims = b.dims)

"""
    mapsamples(f, batch)
    mapsamples(f, batch, batches...)

Apply `f` to each sample in a [`XAIBase.Batch`](@ref) and stack the results into a new `Batch`.
When called with several batches, `f` is called on corresponding samples, like `map`.

All results of `f` need to have the same size.
If `f` changes the number of dimensions of the samples,
a batch dimension that was the last dimension of `batch` remains the last dimension.
Otherwise, the batch dimension keeps its index.
"""
function mapsamples(f, b::Batch, bs::Batch...)
    n = size(b.val, b.dims)
    for bi in bs
        m = size(bi.val, bi.dims)
        m != n && throw(DimensionMismatch("batches contain $n and $m samples"))
    end
    ys = map(f, eachsample(b), map(eachsample, bs)...)
    N = ndims(first(ys)) + 1
    dims = b.dims == ndims(b.val) ? N : min(b.dims, N)
    return Batch(stack(ys; dims), dims)
end
