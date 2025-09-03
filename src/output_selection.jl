const NOTE_OUTPUT_SELECTOR = "## Note
XAIBase assumes that the output of a model is a matrix of logits and that the batch dimension is the last dimension of the output.
"

"""
Abstract super type of all output selectors in XAIBase.

Output selectors are expected to be callable and to return a vector of `CartesianIndex`
of the selected outputs.

$NOTE_OUTPUT_SELECTOR
"""
abstract type AbstractOutputSelector end

(::AbstractOutputSelector)(::AbstractVector) = throw(
    ArgumentError(
        "The output is a 1D vector and therefore missing the required batch dimension.
        XAIBase assumes that the batch dimension is the last dimension of the output."
    )
)

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
(::MaxActivationSelector)(out::AbstractMatrix) = vec(argmax(out; dims = 1))

"""
    IndexSelector(index)

Output selector that picks the output at the given index.
If multiple indices are provided, outputs of a batch are selected separately.

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

julia> output_selector = IndexSelector((1, 1, 2));

julia> output_selector(output)
3-element Vector{CartesianIndex{2}}:
 CartesianIndex(1, 1)
 CartesianIndex(1, 2)
 CartesianIndex(2, 3)
```
"""
struct IndexSelector{I <: Union{Integer, Tuple, AbstractArray{<:Integer}}} <: AbstractOutputSelector
    index::I
end
function (s::IndexSelector{<:Integer})(out::AbstractMatrix)
    batchsize = size(out, 2)
    return [CartesianIndex{2}(s.index, b) for b in 1:batchsize]
end
function (s::IndexSelector{I})(out::AbstractMatrix) where {I <: Union{Tuple, AbstractArray{<:Integer}}}
    length(s.index) != size(out, 2) && throw(DimensionMismatch("Mismatch in batch dimension of output tensor and indices of output selector."))
    return [CartesianIndex{2}(i, b) for (b, i) in enumerate(s.index)]
end
