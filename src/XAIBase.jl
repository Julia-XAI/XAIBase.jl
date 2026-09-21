module XAIBase

include("compat.jl")
include("utils.jl")

"""
Abstract super type of all XAI methods.

It is expected that all XAI methods are callable types that return an `Attribution`:

```julia
(method::AbstractXAIMethod)(input, output_selector::AbstractOutputSelector)
```

If this function is implemented, XAIBase will provide the `analyze` functionality
and `heatmap` functionality by loading either VisionHeatmaps.jl or TextHeatmaps.jl.
"""
abstract type AbstractXAIMethod end

include("exceptions.jl")

# Output selectors of type `AbstractOutputSelector` for class-specific attributions.
# These are used to automatically select the maximally activated output.
include("output_selection.jl")

# Transforms of type `AbstractTransform`, e.g. pooling and normalization functions,
# which can be composed into a `Pipeline` using `|>`.
include("pipeline.jl")

# Feature-attribution pooling functions of type `AbstractPooling` that reduce
# attributions over a feature dimension,
# e.g. to project them onto a human-interpretable space.
include("pooling.jl")

# Normalization functions of type `AbstractNormalization` that rescale pooled
# attributions onto the unit interval, e.g. before applying a colormap.
include("normalization.jl")

# Return type `Attribution` expected of `AbstractXAIMethod`s.
include("attribution.jl")

# User-facing API of XAI methods.
# This file defines the `analyze` function at the core of Julia-XAI methods,
# which in turn calls `(method)(input, output_selector)`.
include("analyze.jl")

# Utilities for XAI methods that compute Attributions w.r.t. specific features:
include("feature_selection.jl")

# Developer-facing interface test that checks a method against the XAIBase contract.
include("test_interface.jl")

export AbstractXAIMethod
export Attribution
export analyze
export AbstractOutputSelector, MaxActivationSelector, IndexSelector
export AbstractFeatureSelector, IndexedFeatures, TopNFeatures
export AbstractPooling, UnsignedPooling, SignedPooling
export SumPooling, MaxPooling
export SumAbsPooling, AbsSumPooling, MaxAbsPooling, NormPooling, SquaredNormPooling
export SignedNoPooling, UnsignedNoPooling
export pool
export AbstractNormalization, ExtremaNormalization, CenteredNormalization
export normalization_bounds, default_normalization
# `normalize` is deliberately not exported to avoid clashing with `LinearAlgebra.normalize`
# `AbstractTransform` and `Pipeline` are deliberately not exported to avoid name clashes,
# e.g. with `MLJ.Pipeline`. Downstream packages that apply transforms re-export them.
end #module
