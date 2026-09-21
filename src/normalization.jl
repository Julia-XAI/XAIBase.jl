const NOTE_NORMALIZATION = """## Note
Normalization is the step between feature-attribution pooling and colormapping:
it linearly rescales pooled attribution values onto the unit interval `[0, 1]`,
which colormaps expect as input.

The appropriate normalization depends on the sign of the pooled values
and is therefore determined by the pooling function's supertype
(see [`default_normalization`](@ref)).
"""

"""
Abstract super type of all normalization functions in XAIBase.

Normalization functions are fieldless structs
that linearly rescale arrays of pooled attribution values
onto the unit interval `[0, 1]` via [`XAIBase.normalize`](@ref).
The value range that is mapped onto `[0, 1]` is computed by [`normalization_bounds`](@ref).

$NOTE_NORMALIZATION
"""
abstract type AbstractNormalization <: AbstractTransform end

"""
    normalize(normalization, A)
    normalize(normalization, A, bounds)

Rescale the values of array `A` linearly onto the unit interval `[0, 1]`
using the normalization function `normalization`, an [`AbstractNormalization`](@ref).
The value range `bounds = (lo, hi)` is mapped onto `[0, 1]` and values outside of it are clamped.
If `bounds` is not provided, it is computed from `A` via [`normalization_bounds`](@ref normalization_bounds).

For convenience, `normalization(A)` is equivalent to `normalize(normalization, A)`.

Passing precomputed `bounds` normalizes `A` to a shared value range,
e.g. to make heatmaps comparable across all samples in a batch:

```julia
bounds = normalization_bounds(normalization, batch)
slices = [normalize(normalization, x, bounds) for x in eachslice(batch; dims = 4)]
```

!!! note "Degenerate value ranges"
    If the value range is degenerate (`lo == hi`, e.g. for a constant array),
    all values are mapped onto the midpoint `0.5`.

!!! warning "Not exported"
    `normalize` is deliberately not exported to avoid name clashes,
    e.g. with `LinearAlgebra.normalize`.
    Use the callable syntax `normalization(A)` or qualify the call as `XAIBase.normalize`.

$NOTE_NORMALIZATION
"""
function normalize(
        n::AbstractNormalization, A::AbstractArray,
        bounds::Tuple{<:Real, <:Real} = normalization_bounds(n, A),
    )
    lo, hi = bounds
    lo > hi && throw(ArgumentError("normalization bounds ($lo, $hi) require lo ≤ hi"))
    lo == hi && return fill!(similar(A, float(eltype(A))), 0.5)
    return clamp.((A .- lo) ./ (hi - lo), 0, 1)
end

# Callable syntax `normalization(A)` delegates to `normalize(normalization, A)`
(n::AbstractNormalization)(A::AbstractArray) = normalize(n, A)
(n::AbstractNormalization)(A::AbstractArray, bounds::Tuple{<:Real, <:Real}) =
    normalize(n, A, bounds)

# Batches are normalized sample by sample, unless a shared value range is passed
normalize(n::AbstractNormalization, b::Batch) = mapsamples(n, b)
function normalize(n::AbstractNormalization, b::Batch, bounds::Tuple{<:Real, <:Real})
    return Batch(normalize(n, b.val, bounds), b.dims)
end
(n::AbstractNormalization)(b::Batch) = normalize(n, b)
(n::AbstractNormalization)(b::Batch, bounds::Tuple{<:Real, <:Real}) = normalize(n, b, bounds)

"""
    normalization_bounds(normalization, A)

Compute the value range `(lo, hi)` of `A`
that [`XAIBase.normalize`](@ref) maps onto the unit interval `[0, 1]`.

`A` can be an array or any iterator of real values.
This allows bounds to be computed across a whole batch of arrays,
e.g. via `Iterators.flatten`, for normalization to a shared value range.

$NOTE_NORMALIZATION
"""
function normalization_bounds end

#===========================#
# Normalization functions   #
#===========================#

"""
    ExtremaNormalization()

Normalization that linearly maps the value range `(minimum(A), maximum(A))`
onto the unit interval `[0, 1]`.

`ExtremaNormalization` is a suitable normalization for unsigned attributions ([`UnsignedPooling`](@ref)),
which are visualized with a sequential colormap.

$NOTE_NORMALIZATION
"""
struct ExtremaNormalization <: AbstractNormalization end
normalization_bounds(::ExtremaNormalization, A) = extrema(A)

"""
    CenteredNormalization()

Normalization that linearly maps the symmetric value range
`(-maximum(abs, A), maximum(abs, A))` onto the unit interval `[0, 1]`,
mapping the value zero onto the midpoint `0.5`.

`CenteredNormalization` is the natural normalization for signed attributions ([`SignedPooling`](@ref)),
which are visualized with a diverging colormap whose neutral midpoint then corresponds to zero attribution.

$NOTE_NORMALIZATION
"""
struct CenteredNormalization <: AbstractNormalization end
function normalization_bounds(::CenteredNormalization, A)
    hi = maximum(abs, A)
    return (-hi, hi)
end

"""
    BatchedNormalization(normalization)

Normalize a whole [`XAIBase.Batch`](@ref) at once,
computing a shared value range over all samples via [`normalization_bounds`](@ref).
This makes heatmaps comparable across the samples in a batch.

By default, normalization functions normalize each sample in a batch separately.
On single samples, `BatchedNormalization(normalization)` behaves like `normalization`.

$NOTE_NORMALIZATION
"""
struct BatchedNormalization{N <: AbstractNormalization} <: AbstractNormalization
    normalization::N
end
function normalization_bounds(n::BatchedNormalization, A)
    return normalization_bounds(n.normalization, A)
end
normalize(n::BatchedNormalization, b::Batch) = Batch(normalize(n, b.val), b.dims)

function Base.show(io::IO, n::BatchedNormalization)
    return print(io, "BatchedNormalization(", n.normalization, ")")
end

#==========================================#
# Coupling to feature-attribution pooling  #
#==========================================#

"""
    default_normalization(pooling)

Return the natural [`AbstractNormalization`](@ref) for the given feature-attribution pooling function,
determined by the sign of the pooling's output:

- [`UnsignedPooling`](@ref) → [`ExtremaNormalization`](@ref) (sequential colormap)
- [`SignedPooling`](@ref) → [`CenteredNormalization`](@ref) (diverging colormap)
"""
default_normalization(::UnsignedPooling) = ExtremaNormalization()
default_normalization(::SignedPooling) = CenteredNormalization()
