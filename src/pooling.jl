const NOTE_POOLING = """## Note
Attribution pooling projects a high-dimensional attribution (e.g. RGB values per pixel)
onto a lower-dimensional, human-interpretable space (e.g. a single value per pixel)
by reducing over a feature dimension `dims` (typically the color-channel dimension `3`
of a `(width, height, channels, batch)` array).

The pooled dimension is dropped,
e.g. an array of size `(W, H, C, N)` is reduced to size `(W, H, N)`.

Pooling functions are documented by their action on a single slice
``a = (a_1, \\ldots, a_n)`` along the pooled dimension `dims`.
"""

"""
Abstract super type of all attribution pooling functions in XAIBase.

Pooling functions are fieldless structs that reduce an array over a feature dimension via [`pool`](@ref).
They are subtypes of either [`UnsignedPooling`](@ref) or [`SignedPooling`](@ref),
depending on whether their output is non-negative or signed.

$NOTE_POOLING
"""
abstract type AbstractPooling <: AbstractTransform end

"""
Abstract super type of attribution pooling functions with unsigned output,
e.g. [`SumAbsPooling`](@ref), [`AbsSumPooling`](@ref), [`MaxAbsPooling`](@ref),
[`NormPooling`](@ref) and [`SquaredNormPooling`](@ref).

Unsigned attributions are best visualized using a sequential colormap.
"""
abstract type UnsignedPooling <: AbstractPooling end

"""
Abstract super type of attribution pooling functions with signed output,
e.g. [`SumPooling`](@ref) and [`MaxPooling`](@ref).

Signed attributions are best visualized using a diverging colormap.
"""
abstract type SignedPooling <: AbstractPooling end

"""
    pool(pooling, A, dims)

Reduce array `A` over the feature dimension `dims`
using the attribution pooling function `pooling`, an [`AbstractPooling`](@ref).

For convenience, `pooling(A, dims)` is equivalent to `pool(pooling, A, dims)`.

`A` can also be a [`XAIBase.Batch`](@ref),
whose batch dimension is updated to account for the dropped dimension.
The batch dimension itself can't be pooled.

Custom pooling functions implement `pool(pooling, A::AbstractArray, dims)`,
which has to drop the pooled dimension.

$NOTE_POOLING
"""
function pool end

# Callable syntax `pooling(A, dims)` delegates to `pool(pooling, A, dims)`
(pooling::AbstractPooling)(A::AbstractArray, dims) = pool(pooling, A, dims)
(pooling::AbstractPooling)(b::Batch, dims) = pool(pooling, b, dims)

# Batches are pooled as a whole
function pool(pooling::AbstractPooling, b::Batch, dims)
    batchdims = batchdims_after_dropdims(b.dims, dims)
    return Batch(pool(pooling, b.val, dims), batchdims)
end

# Index of the batch dimension `batchdims` after dropping the dimensions `dims`,
# which can be an integer or a collection of integers.
# Each dropped dimension in front of the batch dimension shifts it by one.
function batchdims_after_dropdims(batchdims::Integer, dims)
    batchdims in dims &&
        throw(ArgumentError("can't pool over the batch dimension $batchdims of a batch"))
    return batchdims - count(<(batchdims), dims)
end

#===========================#
# Identity poolings         #
#===========================#

# Identity poolings don't reduce features, they can only drop singleton dimensions
function drop_singleton_features(pooling::AbstractPooling, A::AbstractArray, dims)
    all(d -> size(A, d) == 1, dims) || throw(
        ArgumentError(
            "$pooling can't reduce features: array of size $(size(A)) requires singleton feature dimension $dims",
        ),
    )
    return dropdims(A; dims)
end

"""
    SignedNoPooling()

Identity pooling that leaves values unchanged and only drops the feature dimension `dims`,
which has to be a singleton.

Use `SignedNoPooling` for attributions that are already reduced along the feature dimension and therefore require no pooling.
`SignedNoPooling` subtypes [`SignedPooling`](@ref)
and is therefore visualized using a diverging colormap.

For attributions that are guaranteed to be non-negative, use [`UnsignedNoPooling`](@ref).
"""
struct SignedNoPooling <: SignedPooling end
pool(p::SignedNoPooling, A::AbstractArray, dims) = drop_singleton_features(p, A, dims)

"""
    UnsignedNoPooling()

Identity pooling that leaves values unchanged and only drops the feature dimension `dims`,
which has to be a singleton.

Use `UnsignedNoPooling` for attributions that are already reduced along the feature dimension *and* guaranteed to be non-negative.
`UnsignedNoPooling` subtypes [`UnsignedPooling`](@ref)
and is therefore visualized using a sequential colormap.

For attributions of unknown sign, use [`SignedNoPooling`](@ref).
"""
struct UnsignedNoPooling <: UnsignedPooling end
pool(p::UnsignedNoPooling, A::AbstractArray, dims) = drop_singleton_features(p, A, dims)

#===========================#
# Signed pooling functions  #
#===========================#

"""
    SumPooling()

Sum-pooling ``\\sum_i a_i`` over the feature dimension. Returns signed values.

$NOTE_POOLING
"""
struct SumPooling <: SignedPooling end
pool(::SumPooling, A::AbstractArray, dims) = dropdims(sum(A; dims); dims)

"""
    MaxPooling()

Max-pooling ``\\max_i a_i`` over the feature dimension. Returns signed values.

$NOTE_POOLING
"""
struct MaxPooling <: SignedPooling end
pool(::MaxPooling, A::AbstractArray, dims) = dropdims(maximum(A; dims); dims)

#=================================#
# Non-negative pooling functions  #
#=================================#

"""
    SumAbsPooling()

Sum-of-absolute-values pooling ``\\sum_i |a_i|`` (``\\ell^1``-norm) over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct SumAbsPooling <: UnsignedPooling end
pool(::SumAbsPooling, A::AbstractArray, dims) = dropdims(sum(abs, A; dims); dims)

"""
    AbsSumPooling()

Absolute-value-of-sum pooling ``\\left| \\sum_i a_i \\right|`` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct AbsSumPooling <: UnsignedPooling end
pool(::AbsSumPooling, A::AbstractArray, dims) = abs.(dropdims(sum(A; dims); dims))

"""
    MaxAbsPooling()

Maximum-absolute-value pooling ``\\max_i |a_i|`` (``\\ell^\\infty``-norm) over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct MaxAbsPooling <: UnsignedPooling end
pool(::MaxAbsPooling, A::AbstractArray, dims) = dropdims(maximum(abs, A; dims); dims)

"""
    NormPooling()

``\\ell^2``-norm pooling ``\\sqrt{\\sum_i a_i^2}`` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct NormPooling <: UnsignedPooling end
pool(::NormPooling, A::AbstractArray, dims) = sqrt.(dropdims(sum(abs2, A; dims); dims))

"""
    SquaredNormPooling()

Squared ``\\ell^2``-norm pooling ``\\sum_i a_i^2`` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct SquaredNormPooling <: UnsignedPooling end
pool(::SquaredNormPooling, A::AbstractArray, dims) = dropdims(sum(abs2, A; dims); dims)
