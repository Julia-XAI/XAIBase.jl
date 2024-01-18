## Using analyzers
Most methods in the Julia-XAI ecosystem work by calling `analyze` on an input and an analyzer:
```@docs
analyze
```

The return type of `analyze` is an `Explanation`:
```@docs
Explanation
```

## Visualizing explanations
`Explanation`s can be visualized using `heatmap`:
```@docs
heatmap
```

## Internals
Neuron selectors:
```@docs
XAIBase.MaxActivationSelector
XAIBase.IndexSelector
```

## Index
```@index
```