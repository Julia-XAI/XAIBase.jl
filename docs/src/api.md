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

## Attribution pooling
```@docs
pool
AbstractPooling
PositivePooling
SignedPooling
SumPooling
MaxPooling
SumAbsPooling
AbsSumPooling
MaxAbsPooling
NormPooling
SquaredNormPooling
SignedNoPooling
PositiveNoPooling
```

## Normalization
After pooling, explanations are normalized onto the unit interval `[0, 1]`
before a colormap is applied:
```@docs
XAIBase.normalize
AbstractNormalization
ExtremaNormalization
CenteredNormalization
normalization_bounds
default_normalization
```

## Index
```@index
```
