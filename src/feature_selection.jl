const NOTE_FEATURE_SELECTOR = """## Note
The XAIBase interface currently assumes that features have either 2 or 4 dimensions
(`(features, batchsize)` or `(width, height, features, batchsize)`).

It also assumes that the batch dimension is the last dimension of the feature.
"""

"""
Abstract super type of all feature selectors in XAIBase.

Feature selectors are expected to be callable and to return a vector of `CartesianIndices`
for each selected feature.

$NOTE_FEATURE_SELECTOR
"""
abstract type AbstractFeatureSelector end

# Expected interfaces:
# - Calls to feature selector that return a list of lists of `CartesianIndices`
#   - (c::FeatureSelector)(R::AbstractArray{T,N}) where {T,2}
#   - (c::FeatureSelector)(R::AbstractArray{T,N}) where {T,4}
# - number_of_features(c::FeatureSelector)

"""
    IndexedFeatures(indices...)

Select features by indices.

For outputs of convolutional layers, the index refers to a feature dimension.

See also See also [`TopNFeatures`](@ref).

$NOTE_FEATURE_SELECTOR

## Example
```julia-repl
julia> feature_selector = IndexedFeatures(2, 3)
 IndexedFeatures(2, 3)

julia> feature = rand(3, 3, 3, 2);

julia> feature_selector(feature)
2-element Vector{Vector{CartesianIndices{4, NTuple{4, UnitRange{Int64}}}}}:
 [CartesianIndices((1:3, 1:3, 2:2, 1:1)), CartesianIndices((1:3, 1:3, 2:2, 2:2))]
 [CartesianIndices((1:3, 1:3, 3:3, 1:1)), CartesianIndices((1:3, 1:3, 3:3, 2:2))]

julia> feature = rand(3, 2);

julia> feature_selector(feature)
 1-element Vector{Vector{CartesianIndices{2, Tuple{UnitRange{Int64}, UnitRange{Int64}}}}}:
  [CartesianIndices((2:2, 1:1)), CartesianIndices((2:2, 2:2))]
```
"""
struct IndexedFeatures{N} <: AbstractFeatureSelector
    inds::NTuple{N,Int}

    function IndexedFeatures(inds::NTuple{N}) where {N}
        for i in inds
            i > 0 || throw(ArgumentError("All indices have to be greater than 0"))
        end
        return new{N}(inds)
    end
end
IndexedFeatures(args...) = IndexedFeatures(tuple(args...))

number_of_features(c::IndexedFeatures) = length(c.inds)

# Pretty printing
Base.show(io::IO, c::IndexedFeatures) = print(io, "IndexedFeatures$(c.inds)")

# Index features on 2D arrays, e.g. Dense layers with batch dimension
function (c::IndexedFeatures)(A::AbstractMatrix)
    batchsize = size(A, 2)
    return [[CartesianIndices((i:i, b:b)) for b in 1:batchsize] for i in c.inds]
end

# Index features on 4D arrays, e.g. Conv layers with batch dimension
function (c::IndexedFeatures)(A::AbstractArray{T,4}) where {T}
    w, h, _c, batchsize = size(A)
    return [[CartesianIndices((1:w, 1:h, i:i, b:b)) for b in 1:batchsize] for i in c.inds]
end

"""
    TopNFeatures(n)

Select top-n features.

For outputs of convolutional layers, the relevance is summed across height and width
channels for each feature.

See also [`IndexedFeatures`](@ref).

$NOTE_FEATURE_SELECTOR

## Example
```julia-repl
julia> feature_selector = TopNFeatures(2)
 TopNFeatures(2)

julia> feature = rand(3, 2)
3×2 Matrix{Float64}:
 0.265312  0.953689
 0.674377  0.172154
 0.649722  0.570809

julia> feature_selector(feature)
2-element Vector{Vector{CartesianIndices{2, Tuple{UnitRange{Int64}, UnitRange{Int64}}}}}:
 [CartesianIndices((2:2, 1:1)), CartesianIndices((1:1, 2:2))]
 [CartesianIndices((3:3, 1:1)), CartesianIndices((3:3, 2:2))]

julia> feature = rand(3, 3, 3, 2);

julia> feature_selector(feature)
2-element Vector{Vector{CartesianIndices{4, NTuple{4, UnitRange{Int64}}}}}:
 [CartesianIndices((1:3, 1:3, 2:2, 1:1)), CartesianIndices((1:3, 1:3, 1:1, 2:2))]
 [CartesianIndices((1:3, 1:3, 1:1, 1:1)), CartesianIndices((1:3, 1:3, 3:3, 2:2))]
```
"""
struct TopNFeatures <: AbstractFeatureSelector
    n::Int

    function TopNFeatures(n)
        n > 0 || throw(ArgumentError("n has to be greater than 0"))
        return new(n)
    end
end

number_of_features(c::TopNFeatures) = c.n

# Extract top features from 2D arrays, e.g. Dense layers with batch dimension
function (c::TopNFeatures)(A::AbstractMatrix)
    n_features = size(A, 1)
    c.n > n_features && throw(TopNDimensionError(c.n, n_features))

    inds = top_n(A, c.n)
    return [
        [CartesianIndices((i:i, b:b)) for (b, i) in enumerate(r)] for r in eachrow(inds)
    ]
end

# Extract top features from 4D array: e.g. Conv layers with batch dimension
function (c::TopNFeatures)(A::AbstractArray{T,4}) where {T}
    w, h, n_features, _batchsize = size(A)
    c.n > n_features && throw(TopNDimensionError(c.n, n_features))

    features = sum(A; dims=(1, 2))[1, 1, :, :] # reduce width and height channels
    inds = top_n(features, c.n)
    return [
        [CartesianIndices((1:w, 1:h, i:i, b:b)) for (b, i) in enumerate(r)] for
        r in eachrow(inds)
    ]
end

function TopNDimensionError(n, nf)
    DimensionMismatch(
        "Attempted to find top $n features, but feature dimensionality is $nf"
    )
end

"""
    top_n(A, n)

For a matrix `A` of size `(rows, batchdims)`, return a matrix of indices of size `(n, batchdims)`
with sorted indices of the top-n entries.

## Example
```julia-repl
julia> A = rand(4, 3)
4×3 Matrix{Float64}:
 0.469809  0.740177  0.100856
 0.96932   0.53207   0.954989
 0.456456  0.837788  0.313662
 0.925512  0.556236  0.0366143

julia> top_n(A, 2)
2×3 Matrix{Int64}:
 2  3  2
 4  1  3
```
"""
top_n(A::AbstractMatrix, n) = mapslices(x -> top_n(x, n), A; dims=1)
top_n(x::AbstractArray, n) = sortperm(x; rev=true)[1:n]
