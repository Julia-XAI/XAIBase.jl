const NOTE_OUTPUT_SELECTOR = """## Note
XAIBase assumes that the batch dimension is the last dimension of the output.
"""

"""
Abstract super type of all output selectors in XAIBase.

Output selectors are expected to be callable and to return a vector of `CartesianIndex`
of the selected outputs.

$NOTE_OUTPUT_SELECTOR
"""
abstract type AbstractOutputSelector end

"""
    MaxActivationSelector()

Output selector that picks the output with the highest activation.

$NOTE_OUTPUT_SELECTOR

## Example
```julia-repl
julia> output = rand(3, 3)
3×3 Matrix{Float64}:
 0.411871  0.313366  0.13402
 0.885562  0.136938  0.465622
 0.498235  0.627209  0.298911

julia> output_selector = MaxActivationSelector()
 MaxActivationSelector()

julia> output_selector(output)
 3-element Vector{CartesianIndex{2}}:
  CartesianIndex(2, 1)
  CartesianIndex(3, 2)
  CartesianIndex(2, 3)
```

"""
struct MaxActivationSelector <: AbstractOutputSelector end
function (::MaxActivationSelector)(out::AbstractArray{T,N}) where {T,N}
    N < 2 && throw(BATCHDIM_MISSING)
    return vec(argmax(out; dims=1:(N - 1)))
end

"""
    IndexSelector(index)

Output selector that picks the output at the given index.

$NOTE_OUTPUT_SELECTOR

## Example
```julia-repl
julia> output = rand(3, 3)
3×3 Matrix{Float64}:
 0.411871  0.313366  0.13402
 0.885562  0.136938  0.465622
 0.498235  0.627209  0.298911

julia> output_selector = IndexSelector(1)
 IndexSelector{Int64}(1)

julia> output_selector(output)
 3-element Vector{CartesianIndex{2}}:
  CartesianIndex(1, 1)
  CartesianIndex(1, 2)
  CartesianIndex(1, 3)
```
"""
struct IndexSelector{I} <: AbstractOutputSelector
    index::I
end
function (s::IndexSelector{<:Integer})(out::AbstractArray{T,N}) where {T,N}
    N < 2 && throw(BATCHDIM_MISSING)
    batchsize = size(out, N)
    return [CartesianIndex{N}(s.index, b) for b in 1:batchsize]
end
function (s::IndexSelector{I})(out::AbstractArray{T,N}) where {I,T,N}
    N < 2 && throw(BATCHDIM_MISSING)
    batchsize = size(out, N)
    return [CartesianIndex{N}(s.index..., b) for b in 1:batchsize]
end
