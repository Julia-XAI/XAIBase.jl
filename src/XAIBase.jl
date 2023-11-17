module XAIBase

using TextHeatmaps
using VisionHeatmaps

# Abstract super type of all XAI methods.
# Is expected that all methods are callable types that return an `Explanation`:
#
#   (method::AbstractXAIMethod)(input, output_selector::AbstractNeuronSelector)::Explanation
#
# If this function is implemented, XAIBase will provide the `analyze` and `heatmap` functionality.
abstract type AbstractXAIMethod end

# Output neuron selectors of type `AbstractNeuronSelector` for class-specific input-space explanations.
# These are used to e.g. automatically select the maximally activated output neuron.
include("neuron_selection.jl")

# Return type `Explanation` expected of `AbstractXAIMethod`s.
include("explanation.jl")

# User-facing API of XAI methods.
# This file defines the `analyze` function at the core of Julia-XAI methods,
# which in turn calls `(method)(input, output_selector)`.
include("analyze.jl")

# Heatmapping for vision and NLP tasks.
include("heatmaps.jl")

# To be removed in next breaking release:
include("deprecated.jl")

export AbstractXAIMethod
export AbstractNeuronSelector
export Explanation
export analyze
export heatmap
end #module
