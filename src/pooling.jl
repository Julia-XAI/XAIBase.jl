const NOTE_POOLING = """## Note
Attribution pooling projects a high-dimensional explanation (e.g. RGB values per pixel)
onto a lower-dimensional, human-interpretable space (e.g. a single value per pixel)
by reducing over a feature dimension `dim` (typically the color-channel dimension `3`
of a `(width, height, channels, batch)` array).

The pooled dimension is kept as a singleton, e.g. an array of size `(W, H, C, N)`
is reduced to size `(W, H, 1, N)`.
"""

"""
Abstract super type of all attribution pooling functions in XAIBase.

Pooling functions are fieldless structs that reduce an array over a feature dimension
via [`pool`](@ref). They are subtypes of either [`PositivePooling`](@ref) or
[`SignedPooling`](@ref), depending on whether their output is non-negative or signed.

$NOTE_POOLING
"""
abstract type AbstractPooling end

"""
Abstract super type of attribution pooling functions with **non-negative** output,
e.g. [`L1Pool`](@ref), [`NormPool`](@ref), [`LInfPool`](@ref) and [`SquaredNormPool`](@ref).

Non-negative explanations are best visualized using a sequential colormap.
"""
abstract type PositivePooling <: AbstractPooling end

"""
Abstract super type of attribution pooling functions with **signed** output,
e.g. [`SumPool`](@ref) and [`MaxPool`](@ref).

Signed explanations are best visualized using a diverging colormap.
"""
abstract type SignedPooling <: AbstractPooling end

"""
    pool(pooling, A, dim)

Reduce array `A` over the feature dimension `dim` using the attribution pooling
function `pooling`, an [`AbstractPooling`](@ref).

For convenience, `pooling(A, dim)` is equivalent to `pool(pooling, A, dim)`.

$NOTE_POOLING
"""
function pool end

# Callable syntax `pooling(A, dim)` delegates to `pool(pooling, A, dim)`
(pooling::AbstractPooling)(A::AbstractArray, dim) = pool(pooling, A, dim)

#===========================#
# Signed pooling functions  #
#===========================#

"""
    SumPool()

Sum-pooling `∑ aᵢ` over the feature dimension. Returns signed values.

Sum-pooling preserves the conservation property of relevance-based methods such as LRP,
but is prone to sign cancellation across features.

$NOTE_POOLING
"""
struct SumPool <: SignedPooling end
pool(::SumPool, A::AbstractArray, dim) = sum(A; dims = dim)

"""
    MaxPool()

Max-pooling `max(aᵢ)` over the feature dimension. Returns signed values.

$NOTE_POOLING
"""
struct MaxPool <: SignedPooling end
pool(::MaxPool, A::AbstractArray, dim) = maximum(A; dims = dim)

#=================================#
# Non-negative pooling functions  #
#=================================#

"""
    L1Pool()

``\\ell^1``-norm pooling `∑ |aᵢ|` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct L1Pool <: PositivePooling end
pool(::L1Pool, A::AbstractArray, dim) = sum(abs, A; dims = dim)

"""
    NormPool()

``\\ell^2``-norm pooling `√(∑ aᵢ²)` over the feature dimension.
Returns non-negative values.

Norm-pooling avoids sign cancellation across features and is the natural choice
for gradient-based methods.

$NOTE_POOLING
"""
struct NormPool <: PositivePooling end
pool(::NormPool, A::AbstractArray, dim) = sqrt.(sum(abs2, A; dims = dim))

"""
    LInfPool()

``\\ell^\\infty``-norm pooling `max(|aᵢ|)` over the feature dimension.
Returns non-negative values.

$NOTE_POOLING
"""
struct LInfPool <: PositivePooling end
pool(::LInfPool, A::AbstractArray, dim) = maximum(abs, A; dims = dim)

"""
    SquaredNormPool()

Squared ``\\ell^2``-norm pooling `∑ aᵢ²` over the feature dimension.
Returns non-negative values.

Note that squared ``\\ell^2``-norm pooling is equivalent to sum-pooling squared attributions,
blurring the line between interpretability method and pooling function
(e.g. for SmoothGrad-Squared).

$NOTE_POOLING
"""
struct SquaredNormPool <: PositivePooling end
pool(::SquaredNormPool, A::AbstractArray, dim) = sum(abs2, A; dims = dim)
