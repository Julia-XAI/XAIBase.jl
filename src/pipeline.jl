# Pipelines are strongly inspired by the design of DataAugmentations.jl.
# Notably, the usage of the `compose` function has been adapted directly.
# DataAugmentations.jl uses the MIT License,
# Copyright (c) 2020 lorenzoh <lorenz.ohly@gmail.com>

"""
    AbstractTransform

Abstract super type of all transforms of attributions,
e.g. feature-attribution pooling functions ([`AbstractPooling`](@ref))
and normalization functions ([`AbstractNormalization`](@ref)).

Transforms can be composed into a [`Pipeline`](@ref) using `|>`.
XAIBase only defines the composition of transforms:
how transforms are applied is defined by downstream packages,
e.g. VisionHeatmaps.jl and TextHeatmaps.jl.

!!! warning "Not exported"
    `AbstractTransform` is deliberately not exported to avoid name clashes.
    Downstream packages that apply transforms re-export it.
"""
abstract type AbstractTransform end

"""
    Pipeline(transforms...)

Sequentially apply transforms of type [`AbstractTransform`](@ref).
Pipelines are usually created by composing transforms using `|>`:

```julia
pipeline = NormPooling() |> ExtremaNormalization()
```

!!! warning "Not exported"
    `Pipeline` is deliberately not exported to avoid name clashes,
    e.g. with `MLJ.Pipeline`.
    Downstream packages that apply pipelines re-export it.
"""
struct Pipeline{T <: Tuple} <: AbstractTransform
    transforms::T
end

Pipeline(ts::AbstractTransform...) = Pipeline(ts)
Pipeline(t::AbstractTransform) = t

"""
    compose(transforms...)

Compose transforms of type [`AbstractTransform`](@ref) to create a [`Pipeline`](@ref).
Nested pipelines are flattened.
`t1 |> t2` is an alias for `compose(t1, t2)`.
"""
compose(t::AbstractTransform) = t
compose(ts::AbstractTransform...) = compose(compose(ts[1], ts[2]), ts[3:end]...)
Base.:(|>)(t1::AbstractTransform, t2::AbstractTransform) = compose(t1, t2)

compose(t1::AbstractTransform, t2::AbstractTransform) = Pipeline(t1, t2)
compose(p::Pipeline, t::AbstractTransform) = Pipeline(p.transforms..., t)
compose(t::AbstractTransform, p::Pipeline) = compose(t, p.transforms...)
compose(p1::Pipeline, p2::Pipeline) = compose(p1.transforms..., p2.transforms...)

function Base.show(io::IO, pipe::Pipeline)
    println(io, "Pipeline(")
    for t in pipe.transforms
        println(io, "  ", t, ",")
    end
    return print(io, ")")
end
