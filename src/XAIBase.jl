module XAIBase

include("compat.jl")
include("utils.jl")

"""
Abstract super type of all XAI methods.

It is expected that all XAI methods are callable types that return an `Explanation`:

```julia
(method::AbstractXAIMethod)(input, output_selector::AbstractOutputSelector)
```

If this function is implemented, XAIBase will provide the `analyze` and `heatmap` functionality.
"""
abstract type AbstractXAIMethod end

# Output selectors of type `AbstractOutputSelector` for class-specific explanations.
# These are used to automatically select the maximally activated output.
include("output_selection.jl")

# Return type `Explanation` expected of `AbstractXAIMethod`s.
include("explanation.jl")

# User-facing API of XAI methods.
# This file defines the `analyze` function at the core of Julia-XAI methods,
# which in turn calls `(method)(input, output_selector)`.
include("analyze.jl")

# Utilities for XAI methods that compute Explanations w.r.t. specific features:
include("feature_selection.jl")

export AbstractXAIMethod
export Explanation
export analyze
export AbstractOutputSelector, MaxActivationSelector, IndexSelector
export AbstractFeatureSelector, IndexedFeatures, TopNFeatures
end #module
