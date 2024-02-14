# XAIBase.jl
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://julia-xai.github.io/XAIDocs/XAIBase/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Julia-XAI.github.io/XAIBase.jl/dev/)
[![Build Status](https://github.com/Julia-XAI/XAIBase.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Julia-XAI/XAIBase.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Julia-XAI/XAIBase.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Julia-XAI/XAIBase.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

XAIBase is a light-weight dependency that defines the interface of XAI methods in the [Julia-XAI ecosystem](https://github.com/Julia-XAI),
which focusses on post-hoc, local input space explanations of black-box models.
In simpler terms, methods that try to answer the question 
*"Which part of the input is responsible for the model's output?"*

Building on top of XAIBase (or providing an interface via [package extensions][docs-extensions])
makes your package compatible with the Julia-XAI ecosystem,
allowing you to automatically compute heatmaps for vision and language models. 
It also allows you to use input-augmentations from [ExplainableAI.jl][url-explainableai].

## Interface description
This only requires you to fulfill the following two requirements:

1. An XAI method has to be a subtype of `AbstractXAIMethod`
2. An XAI method has to implement the following method: 

```julia
(method::MyMethod)(input, output_selector::AbstractOutputSelector)
```

* The method has to return an [`Explanation`][docs-explanation]
* The input is expected to have a batch dimensions as its last dimension
* When applied to a batch, the method returns a single [`Explanation`][docs-explanation], 
  which contains the batched output in the `val` field.
* `AbstractOutputSelector`s are predefined callable structs 
  that select a single scalar value from a model's output, 
  e.g. the maximally activated output of a classifier using [`XAIBase.MaxActivationSelector`][docs-maxactivationselector]
  or a specific output using [`XAIBase.IndexSelector`][docs-indexselector].

Refer to the [`Explanation`][docs-explanation] documentation for a description of the expected fields.
For more information, take a look at [`src/XAIBase.jl`](https://github.com/Julia-XAI/XAIBase.jl/blob/main/src/XAIBase.jl).

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
    extras = nothing  # or some additional information
    return Explanation(val, output, output_selection, :MyMethod, :sensitivity, extras)
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
[docs-maxactivationselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.MaxActivationSelector
[docs-indexselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.IndexSelector