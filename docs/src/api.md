# API Reference
```@docs
AbstractXAIMethod
```

## Computing explanations
Most methods in the Julia-XAI ecosystem work by calling `analyze` on an input and an analyzer:
```@docs
analyze
```

The return type of `analyze` is an `Explanation`:
```@docs
Explanation
```

## Feature selection
```@docs
AbstractFeatureSelector
IndexedFeatures
TopNFeatures
```

## Output selection
```@docs
AbstractOutputSelector
MaxActivationSelector
IndexSelector
```

## Index
```@index
```