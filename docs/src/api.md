# API Reference
```@docs
AbstractXAIMethod
```

## Computing feature attributions
Most feature-attribution methods in the Julia-XAI ecosystem work by calling `analyze` on an input and an analyzer:
```@docs
analyze
```

The return type of `analyze` is an `Attribution`:
```@docs
Attribution
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

## Feature-attribution pooling

XAIBase includes the following pooling functions:
```
NormPooling
SumPooling
MaxPooling
SumAbsPooling
AbsSumPooling
MaxAbsPooling
SquaredNormPooling
```

all of which can be called using
```@docs
pool
```

Custom pooling functions can be implemented by subtyping:
```@docs
AbstractPooling
UnsignedPooling
SignedPooling
SignedNoPooling
UnsignedNoPooling
```

## Normalization

After pooling, attributions are normalized onto the unit interval `[0, 1]` before a colormap is applied:
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
