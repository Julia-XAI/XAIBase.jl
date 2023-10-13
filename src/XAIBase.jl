module XAIBase

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

# Heatmapping presets used in package extensions.
# To keep dependencies minimal, heatmapping functionality is loaded via package extensions
# on VisionHeatmaps.jl and TextHeatmaps.jl in the `/ext` folder.
# Shared heatmapping default settings are defined in this file.
include("heatmap_presets.jl")

export AbstractXAIMethod
export AbstractNeuronSelector
export Explanation
export analyze

# Package extension backwards compatibility with Julia 1.6.
# For Julia 1.6, VisionHeatmaps.jl and TextHeatmaps.jl are treated as normal dependencies and always loaded.
# https://pkgdocs.julialang.org/v1/creating-packages/#Transition-from-normal-dependency-to-extension
if !isdefined(Base, :get_extension)
    # include("../ext/VisionHeatmapsExt.jl")
    include("../ext/XAITextHeatmapsExt.jl")
end
end #module
