# XAIBase.jl
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://julia-xai.github.io/XAIDocs/XAIBase/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Julia-XAI.github.io/XAIBase.jl/dev/)
[![Build Status](https://github.com/Julia-XAI/XAIBase.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Julia-XAI/XAIBase.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Julia-XAI/XAIBase.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Julia-XAI/XAIBase.jl)
[![Code Style: Runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)
[![Aqua][aqua-img]][aqua-url]
[![JET][jet-img]][jet-url]
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

XAIBase is a light-weight dependency that defines the interface of XAI methods in the [Julia-XAI ecosystem](https://github.com/Julia-XAI),
which focuses on post-hoc, local feature attributions on the input space of black-box models.
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

1. A feature-attribution method has to be a subtype of [`AbstractXAIMethod`][docs-abstractxaimethod]
2. A feature-attribution method has to implement a `call_analyzer` method:

```julia
import XAIBase: call_analyzer

call_analyzer(input, method::MyMethod, output_selector::AbstractOutputSelector; kwargs...)
```

* `call_analyzer` has to return an [`Attribution`][docs-attribution]
* the input is expected to have a batch dimensions as its last dimension
* when applied to a batch, the method returns a single [`Attribution`][docs-attribution],
  which contains the batched output in the `val` field.
* [`AbstractOutputSelector`][docs-abstractoutputselector]
  are predefined callable structs that select scalar values from a model's output,
  e.g. the maximally activated output of a classifier using [`MaxActivationSelector`][docs-maxactivationselector].

Refer to the [`Attribution`][docs-attribution] documentation for a description of the expected fields.
For more information, take a look at the [documentation][docs].

## Example implementation
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

    val = ...                 # your method's implementation
    pooling = NormPooling()   # how to reduce `val` over its feature dimension
    return Attribution(val, input, output, output_selection, pooling)
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
[docs-attribution]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.Attribution
[docs-abstractxaimethod]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.AbstractXAIMethod
[docs-abstractoutputselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.AbstractOutputSelector
[docs-maxactivationselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.MaxActivationSelector
[docs-indexselector]: https://julia-xai.github.io/XAIDocs/XAIBase/stable/api/#XAIBase.IndexSelector

[aqua-img]: https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl

[jet-img]: https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a
[jet-url]: https://github.com/aviatesk/JET.jl
