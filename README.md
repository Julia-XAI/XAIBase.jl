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
* XAI methods are expected to be subtypes of `AbstractXAIMethod` 
* XAI methods return `Explanation`, which have the following fields:
  * `val`: numerical output of the analyzer, e.g. an attribution or gradient in input space
  * `output`: model output for the given analyzer input
  * `output_selection`: index of the output used for the explanation, 
    e.g. an output neuron corresponding to a specific class in a classification model
  * `analyzer`: symbol corresponding the used analyzer, e.g. `:Gradient` or `:MyMethod`.
    This is primarily used to define heatmapping presets
  * `heatmap`: symbol indicating a preset heatmapping style,
    e.g. `:attribution`, `:sensitivity` or `:cam`
  * `extras`: optional named tuple that can be used by analyzers
    to return additional information
* XAI methods need to implement a single function 
  ```julia
  (method::MyMethod)(input, output_selector::AbstractNeuronSelector)::Explanation
  ```
  * `AbstractNeuronSelector`s are predefined callable structs 
    that select a single scalar value from a model's output, 
    e.g. the maximally activated output neuron of a classifier using `MaxActivationSelector`
  * The input is expected to have a batch dimensions as its last dimension
  * When applied to a batch, the method returns a single `Explanation`, 
    which contains the batched output in the `val` field.

## Example implementation
```julia
struct MyMethod{M} <: AbstractXAIMethod 
    model::M    
end

function (method::MyMethod)(input, output_selector::AbstractNeuronSelector)
    output = method.model(input)
    output_selection = output_selector(output)

    val = ...         # your method's implementation
    extras = nothing  # or some additional information
    return Explanation(val, output, output_selection, :MyMethod, :sensitivity, extras)
end
```

For more information, take a look at `src/XAIBase.jl`.

## Acknowledgements
> Adrian Hill acknowledges support by the Federal Ministry of Education and Research (BMBF) 
> for the Berlin Institute for the Foundations of Learning and Data (BIFOLD) (01IS18037A).

<!-- URLs -->
[url-org]: https://github.com/Julia-XAI
[url-explainableai]: https://github.com/Julia-XAI/ExplainableAI.jl
[docs-extensions]: https://pkgdocs.julialang.org/v1/creating-packages/#Conditional-loading-of-code-in-packages-(Extensions)