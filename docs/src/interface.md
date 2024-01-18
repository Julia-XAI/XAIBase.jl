## [Interface description](@id docs-interface)

XAIBase.jl is a light-weight dependency that defines the interface of XAI methods 
in the [Julia-XAI ecosystem](https://github.com/Julia-XAI),
which focusses on post-hoc, local input space explanations of black-box models.
In simpler terms, methods that try to answer the question 
*"Which part of the input is responsible for the model's output?"*

Building on top of XAIBase 
(or providing an interface via [package extensions](https://pkgdocs.julialang.org/v1/creating-packages/#Conditional-loading-of-code-in-packages-(Extensions)))
makes your package compatible with the Julia-XAI ecosystem,
allowing you to automatically compute heatmaps for vision and language models. 

This only requires you to fulfill the following two requirements:

1. An XAI method has to be a subtype of `AbstractXAIMethod`
2. An XAI method has to implement the following method: 

```julia
(method::MyMethod)(input, output_selector::AbstractNeuronSelector)
```

* The method has to return an [`Explanation`](@ref)
* The input is expected to have a batch dimensions as its last dimension
* When applied to a batch, the method returns a single [`Explanation`](@ref), 
  which contains the batched output in the `val` field.
* `AbstractNeuronSelector`s are predefined callable structs 
  that select a single scalar value from a model's output, 
  e.g. the maximally activated output neuron of a classifier using [`XAIBase.MaxActivationSelector`](@ref)
  or a specific output neuron using [`XAIBase.IndexSelector`](@ref).

Refer to the [`Explanation`](@ref) documentation for a description of the expected fields.
For more information, take a look at [`src/XAIBase.jl`](https://github.com/Julia-XAI/XAIBase.jl/blob/main/src/XAIBase.jl).

## Example implementation
```julia
struct MyMethod{M} <: AbstractXAIMethod 
    model::M    
end

function (method::MyMethod)(input, output_selector::AbstractNeuronSelector)
    output = method.model(input)
    output_selection = output_selector(output)

    val = ...         # your method's implementation
    extras = nothing  # optionally add additional information using a named tuple
    return Explanation(val, output, output_selection, :MyMethod, :attribution, extras)
end
```
