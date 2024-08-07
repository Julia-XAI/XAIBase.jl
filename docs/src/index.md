## [Interface description](@id docs-interface)

XAIBase.jl is a light-weight dependency that defines the interface of XAI methods 
in the [Julia-XAI ecosystem](https://julia-xai.github.io/XAIDocs/).

Building on top of XAIBase 
(or providing an interface via [package extensions](https://pkgdocs.julialang.org/v1/creating-packages/#Conditional-loading-of-code-in-packages-(Extensions)))
makes your package compatible with the Julia-XAI ecosystem,
allowing you to automatically compute heatmaps for vision and language models
using [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/)
and [TextHeatmaps.jl](https://julia-xai.github.io/XAIDocs/TextHeatmaps/stable/).

This only requires you to fulfill the following two requirements:

1. An XAI method has to be a subtype of `AbstractXAIMethod`
2. An XAI algorithm has to implement a `call_analyzer` method: 

```julia
import XAIBase: call_analyzer

call_analyzer(input, method::MyMethod, output_selector::AbstractOutputSelector; kwargs...)
```

* `call_analyzer` has to return an [`Explanation`](@ref)
* The input is expected to have a batch dimensions as its last dimension
* When applied to a batch, the method returns a single [`Explanation`](@ref), 
  which contains the batched output in the `val` field.
* `AbstractOutputSelector`s are predefined callable structs 
  that select a single scalar value from a model's output, 
  e.g. the maximally activated output of a classifier using [`MaxActivationSelector`](@ref)
  or a specific output using [`IndexSelector`](@ref).

Refer to the [`Explanation`](@ref) documentation for a description of the expected fields.
For more information, take a look at [`src/XAIBase.jl`](https://github.com/Julia-XAI/XAIBase.jl/blob/main/src/XAIBase.jl).

## Implementation template 
Julia-XAI methods will usually follow the following template:

```julia
using XAIBase
import XAIBase: call_analyzer

struct MyMethod{M} <: AbstractXAIMethod 
    model::M    
end

function call_analyzer(input, method::MyMethod, output_selector::AbstractOutputSelector; kwargs...)
    output = method.model(input)
    output_selection = output_selector(output)

    val = ...         # your method's implementation
    extras = nothing  # optionally add additional information using a named tuple
    return Explanation(val, input, output, output_selection, :MyMethod, :attribution, extras)
end
```

Refer to the [example implementations](@ref examples) for more information.