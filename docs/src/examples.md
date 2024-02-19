# [Example Implementations](@id examples)
The following examples demonstrate the implementation of XAI methods using the XAIBase.jl interface.
To evaluate our methods, we load a small, pre-trained LeNet5 model and the MNIST dataset:

```@example implementations
using Flux
using BSON

model = BSON.load("model.bson", @__MODULE__)[:model] # load pre-trained LeNet-5 model
```

```@example implementations
using MLDatasets
using ImageCore, ImageIO, ImageShow

index = 10
x, y = MNIST(Float32, :test)[10]

# By convention in Flux.jl, the input needs to be resized to WHCN format
# by adding a color channel and batch dimensions.
input = reshape(x, 28, 28, 1, :);

convert2image(MNIST, x)
```

## Example 1: Random explanation
To get started, we implement a nonsensical method
that returns a random explanation in the shape of the input.

```@example implementations
using XAIBase

struct RandomAnalyzer{M} <: AbstractXAIMethod 
    model::M    
end

function (method::RandomAnalyzer)(input, output_selector::AbstractOutputSelector)
    output = method.model(input)
    output_selection = output_selector(output)

    val = rand(size(input)...)
    return Explanation(val, output, output_selection, :RandomAnalyzer, :sensitivity, nothing)
end
```

We can directly use XAIBase's `analyze` function 
to compute the random explanation:

```@example implementations
analyzer = RandomAnalyzer(model)
expl = analyze(input, analyzer)
```

Using either [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/)
or [TextHeatmaps.jl](https://julia-xai.github.io/XAIDocs/TextHeatmaps/stable/),
which provide package extensions on XAIBase's `Explanation` type,
we can visualize the explanations:

```@example implementations
using VisionHeatmaps # load heatmapping functionality

heatmap(expl.val)
```

As expected, the explanation is just noise.

## Example 2: Input sensitivity
In this second example, we naively reimplement the `Gradient` analyzer from
[ExplainableAI.jl](https://github.com/Julia-XAI/ExplainableAI.jl).

```@example implementations
using XAIBase
using Zygote: gradient

struct MyGradient{M} <: AbstractXAIMethod 
    model::M    
end

function (method::MyGradient)(input, output_selector::AbstractOutputSelector)
    output = method.model(input)
    output_selection = output_selector(output)

    grad = gradient((x) -> only(method.model(x)[output_selection]), input)
    val = only(grad)
    return Explanation(val, output, output_selection, :MyGradient, :sensitivity, nothing)
end
```

!!! note
    [ExplainableAI.jl](https://github.com/Julia-XAI/ExplainableAI.jl)
    implements the `Gradient` analyzer in a more efficient way 
    that works with batched inputs and only requires a single forward 
    and backward pass through the model.

Once again, we can directly use XAIBase's `analyze` and VisionHeatmaps' `heatmap` functions
```@example implementations
using VisionHeatmaps 

analyzer = MyGradient(model)
expl = analyze(input, analyzer)
heatmap(expl.val)
```

```@example implementations
heatmap(expl.val, colorscheme=:twilight, reduce=:norm, rangescale=:centered)
```

and make use of all the features provided by the Julia-XAI ecosystem.

!!! note
    For an introduction to the [Julia-XAI ecosystem](https://github.com/Julia-XAI), 
    please refer to the [*Getting started* guide](https://julia-xai.github.io/XAIDocs/).
