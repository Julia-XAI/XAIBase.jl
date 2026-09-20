const NOTE_POOLING = """## Note
Attribution pooling projects a high-dimensional attribution (e.g. RGB values per pixel)
onto a lower-dimensional, human-interpretable space (e.g. a single value per pixel)
by reducing over a feature dimension `dim` (typically the color-channel dimension `3`
of a `(width, height, channels, batch)` array).

The pooled dimension is kept as a singleton, e.g. an array of size `(W, H, C, N)`
is reduced to size `(W, H, 1, N)`.
"""

"""
Abstract super type of all feature-attribution pooling functions in XAIBase.

Pooling functions are fieldless structs that reduce an array over a feature dimension
via [`pool`](@ref). They are subtypes of either [`UnsignedPooling`](@ref) or
[`SignedPooling`](@ref), depending on whether their output is non-negative or signed.

$NOTE_POOLING
"""
abstract type AbstractPooling end

"""
Abstract super type of feature-attribution pooling functions with **non-negative** output,
e.g. [`SumAbsPooling`](@ref), [`AbsSumPooling`](@ref), [`MaxAbsPooling`](@ref),
[`NormPooling`](@ref) and [`SquaredNormPooling`](@ref).

Non-negative attributions are best visualized using a sequential colormap.
"""
abstract type UnsignedPooling <: AbstractPooling end

"""
Abstract super type of feature-attribution pooling functions with **signed** output,
e.g. [`SumPooling`](@ref) and [`MaxPooling`](@ref).

Signed attributions are best visualized using a diverging colormap.
"""
abstract type SignedPooling <: AbstractPooling end

"""
    pool(pooling, A, dim)

Reduce array `A` over the feature dimension `dim` using the feature-attribution pooling
function `pooling`, an [`AbstractPooling`](@ref).

For convenience, `pooling(A, dim)` is equivalent to `pool(pooling, A, dim)`.

$NOTE_POOLING
"""
function pool end

# Callable syntax `pooling(A, dim)` delegates to `pool(pooling, A, dim)`
(pooling::AbstractPooling)(A::AbstractArray, dim) = pool(pooling, A, dim)

#===========================#
# Identity poolings         #
#===========================#

"""
    SignedNoPooling()

Identity pooling that returns the array unchanged, ignoring `dim`.

Use `SignedNoPooling` for attributions that are already reduced along the feature dimension
and therefore require no pooling. `SignedNoPooling` subtypes [`SignedPooling`](@ref):
it makes no guarantee about the sign of its output, so it is conservatively visualized
using a diverging colormap.

For attributions that are guaranteed to be non-negative, use [`UnsignedNoPooling`](@ref).
"""
struct SignedNoPooling <: SignedPooling end
pool(::SignedNoPooling, A::AbstractArray, dim) = A

"""
    UnsignedNoPooling()

Identity pooling that returns the array unchanged, ignoring `dim`,
asserting that its values are **non-negative**.

Use `UnsignedNoPooling` for attributions that are already reduced along the feature
dimension *and* guaranteed to be non-negative, such as Grad-CAM, whose output is
internally aggregated to a single channel and passed through a ReLU.
`UnsignedNoPooling` subtypes [`UnsignedPooling`](@ref) and is therefore visualized
using a sequential colormap.

For attributions of unknown sign, use [`SignedNoPooling`](@ref).
"""
struct UnsignedNoPooling <: UnsignedPooling end
pool(::UnsignedNoPooling, A::AbstractArray, dim) = A

#===========================#
# Signed pooling functions  #
#===========================#

"""
    SumPooling()

Sum-pooling `∑ aᵢ` over the feature dimension. Returns signed values.

Sum-pooling preserves the conservation property of relevance-based methods such as LRP,
but is prone to sign cancellation across features.

$NOTE_POOLING
"""
struct SumPooling <: SignedPooling end
pool(::SumPooling, A::AbstractArray, dim) = sum(A; dims = dim)

"""
    MaxPooling()

Max-pooling `max(aᵢ)` over the feature dimension. Returns signed values.

$NOTE_POOLING
"""
struct MaxPooling <: SignedPooling end
pool(::MaxPooling, A::AbstractArray, dim) = maximum(A; dims = dim)

#=================================#
# Non-negative pooling functions  #
#=================================#

"""
    SumAbsPooling()

Sum-of-absolute-values pooling `∑ |aᵢ|` (``\\ell^1``-norm) over the feature dimension.
Returns non-negative values.

Unlike [`AbsSumPooling`](@ref), taking absolute values *before* summing
prevents sign cancellation across features.

$NOTE_POOLING
"""
struct SumAbsPooling <: UnsignedPooling end
pool(::SumAbsPooling, A::AbstractArray, dim) = sum(abs, A; dims = dim)

"""
    AbsSumPooling()

Absolute-value-of-sum pooling `|∑ aᵢ|` over the feature dimension.
Returns non-negative values.

Unlike [`SumAbsPooling`](@ref), summing *before* taking the absolute value
allows sign cancellation across features: `AbsSumPooling` measures the magnitude
of the net attribution, matching the conservation-oriented view of [`SumPooling`](@ref)
while discarding its sign.

$NOTE_POOLING
"""
struct AbsSumPooling <: UnsignedPooling end
pool(::AbsSumPooling, A::AbstractArray, dim) = abs.(sum(A; dims = dim))

"""
    MaxAbsPooling()

Maximum-absolute-value pooling `max(|aᵢ|)` (``\\ell^\\infty``-norm) over the feature
dimension. Returns non-negative values.

$NOTE_POOLING
"""
struct MaxAbsPooling <: UnsignedPooling end
pool(::MaxAbsPooling, A::AbstractArray, dim) = maximum(abs, A; dims = dim)

"""
    NormPooling()

``\\ell^2``-norm pooling `√(∑ aᵢ²)` over the feature dimension.
Returns non-negative values.

Norm-pooling avoids sign cancellation across features and is the natural choice
for gradient-based methods.

$NOTE_POOLING
"""
struct NormPooling <: UnsignedPooling end
pool(::NormPooling, A::AbstractArray, dim) = sqrt.(sum(abs2, A; dims = dim))

"""
    SquaredNormPooling()

Squared ``\\ell^2``-norm pooling `∑ aᵢ²` over the feature dimension.
Returns non-negative values.

Note that squared ``\\ell^2``-norm pooling is equivalent to sum-pooling squared attributions,
blurring the line between interpretability method and pooling function
(e.g. for SmoothGrad-Squared).

$NOTE_POOLING
"""
struct SquaredNormPooling <: UnsignedPooling end
pool(::SquaredNormPooling, A::AbstractArray, dim) = sum(abs2, A; dims = dim)
