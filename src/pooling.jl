const NOTE_POOLING = """## Note
Attribution pooling projects a high-dimensional attribution (e.g. RGB values per pixel)
onto a lower-dimensional, human-interpretable space (e.g. a single value per pixel)
by reducing over a feature dimension `dims` (typically the color-channel dimension `3`
of a `(width, height, channels, batch)` array).

The pooled dimension is kept as a singleton,
e.g. an array of size `(W, H, C, N)` is reduced to size `(W, H, 1, N)`.

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
abstract type AbstractPooling end

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

$NOTE_POOLING
"""
function pool end

# Callable syntax `pooling(A, dims)` delegates to `pool(pooling, A, dims)`
(pooling::AbstractPooling)(A::AbstractArray, dims) = pool(pooling, A, dims)

#===========================#
# Identity poolings         #
#===========================#

"""
    SignedNoPooling()

Identity pooling that returns the array unchanged, ignoring `dims`.

Use `SignedNoPooling` for attributions that are already reduced along the feature dimension and therefore require no pooling.
`SignedNoPooling` subtypes [`SignedPooling`](@ref)
and is therefore visualized using a diverging colormap.

For attributions that are guaranteed to be non-negative, use [`UnsignedNoPooling`](@ref).
"""
struct SignedNoPooling <: SignedPooling end
pool(::SignedNoPooling, A::AbstractArray, dims) = A

"""
    UnsignedNoPooling()

Identity pooling that returns the array unchanged, ignoring `dims`.

Use `UnsignedNoPooling` for attributions that are already reduced along the feature dimension *and* guaranteed to be non-negative.
`UnsignedNoPooling` subtypes [`UnsignedPooling`](@ref)
and is therefore visualized using a sequential colormap.

For attributions of unknown sign, use [`SignedNoPooling`](@ref).
"""
struct UnsignedNoPooling <: UnsignedPooling end
pool(::UnsignedNoPooling, A::AbstractArray, dims) = A

#===========================#
# Signed pooling functions  #
#===========================#

"""
    SumPooling()

Sum-pooling ``\\sum_i a_i`` over the feature dimension. Returns signed values.

$NOTE_POOLING
"""
struct SumPooling <: SignedPooling end
pool(::SumPooling, A::AbstractArray, dims) = sum(A; dims = dims)

"""
    MaxPooling()

Max-pooling ``\\max_i a_i`` over the feature dimension. Returns signed values.

$NOTE_POOLING
"""
struct MaxPooling <: SignedPooling end
pool(::MaxPooling, A::AbstractArray, dims) = maximum(A; dims = dims)

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
pool(::SumAbsPooling, A::AbstractArray, dims) = sum(abs, A; dims = dims)

"""
    AbsSumPooling()

Absolute-value-of-sum pooling ``\\left| \\sum_i a_i \\right|`` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct AbsSumPooling <: UnsignedPooling end
pool(::AbsSumPooling, A::AbstractArray, dims) = abs.(sum(A; dims = dims))

"""
    MaxAbsPooling()

Maximum-absolute-value pooling ``\\max_i |a_i|`` (``\\ell^\\infty``-norm) over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct MaxAbsPooling <: UnsignedPooling end
pool(::MaxAbsPooling, A::AbstractArray, dims) = maximum(abs, A; dims = dims)

"""
    NormPooling()

``\\ell^2``-norm pooling ``\\sqrt{\\sum_i a_i^2}`` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct NormPooling <: UnsignedPooling end
pool(::NormPooling, A::AbstractArray, dims) = sqrt.(sum(abs2, A; dims = dims))

"""
    SquaredNormPooling()

Squared ``\\ell^2``-norm pooling ``\\sum_i a_i^2`` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct SquaredNormPooling <: UnsignedPooling end
pool(::SquaredNormPooling, A::AbstractArray, dims) = sum(abs2, A; dims = dims)
