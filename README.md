# XAIBase.jl
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://julia-xai.github.io/XAIDocs/XAIBase/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Julia-XAI.github.io/XAIBase.jl/dev/)
[![Build Status](https://github.com/Julia-XAI/XAIBase.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Julia-XAI/XAIBase.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Julia-XAI/XAIBase.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Julia-XAI/XAIBase.jl)
[![Aqua][aqua-img]][aqua-url] 
[![JET][jet-img]][jet-url]

XAIBase is a light-weight dependency that defines the interface of XAI methods in the [Julia-XAI ecosystem](https://github.com/Julia-XAI),
which focusses on post-hoc, local input space explanations of black-box models.
In simpler terms, methods that try to answer the question 
*"Which part of the input is responsible for the model's output?"*

Building on top of XAIBase (or providing an interface via [package extensions][docs-extensions])
makes your package compatible with the Julia-XAI ecosystem,
allowing you to automatically compute heatmaps for vision and language models
using [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/)
and [TextHeatmaps.jl](https://julia-xai.github.io/XAIDocs/TextHeatmaps/stable/).
It also allows you to use input-augmentations from [ExplainableAI.jl][url-explainableai].

## Interface description
XAIBase only requires you to fulfill the following two requirements:

1. An XAI algorithm has to be a subtype of [`AbstractXAIMethod`][docs-abstractxaimethod]
2. An XAI algorithm has to implement the following method: 

```julia
(method::MyMethod)(input, output_selector::AbstractOutputSelector)
```

* the method has to return an [`Explanation`][docs-explanation]
* the input is expected to have a batch dimensions as its last dimension
* when applied to a batch, the method returns a single [`Explanation`][docs-explanation], 
  which contains the batched output in the `val` field.
* [`AbstractOutputSelector`][docs-abstractoutputselector]
  are predefined callable structs that select scalar values from a model's output, 
  e.g. the maximally activated output of a classifier using [`MaxActivationSelector`][docs-maxactivationselector].

Refer to the [`Explanation`][docs-explanation] documentation for a description of the expected fields.
For more information, take a look at the [documentation][docs].

## Example implementation
Julia-XAI methods will usually follow the following template:

```julia
struct MyMethod{M} <: AbstractXAIMethod 
    model::M    
end

function (method::MyMethod)(input, output_selector::AbstractOutputSelector)
    output = method.model(input)
    output_selection = output_selector(output)

    val = ...         # your method's implementation
    extras = nothing  # optionally add additional information using a named tuple
    return Explanation(val, output, output_selection, :MyMethod, :attribution, extras)
end
```

> [!TIP]
> For full implementation examples, refer to the 
> [examples in the XAIBase documentation](https://julia-xai.github.io/XAIDocs/XAIBase/dev/examples/).

## Acknowledgements
> Adrian Hill acknowledges support by the Federal Ministry of Education and Research (BMBF) 
> for the Berlin Institute for the Foundations of Learning and Data (BIFOLD) (01IS18037A).

<!-- URLs -->
[url-org]: https://github.com/Julia-XAI
[url-explainableai]: https://github.com/Julia-XAI/ExplainableAI.jl
[docs-extensions]: https://pkgdocs.julialang.org/v1/creating-packages/#Conditional-loading-of-code-in-packages-(Extensions)
[docs]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/
[docs-explanation]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.Explanation
[docs-abstractxaimethod]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.AbstractXAIMethod
[docs-abstractoutputselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.AbstractOutputSelector
[docs-maxactivationselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.MaxActivationSelector
[docs-indexselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.IndexSelector

[aqua-img]: https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl

[jet-img]: https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a
[jet-url]: https://github.com/aviatesk/JET.jl
