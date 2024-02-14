abstract type AbstractOutputSelector end

"""
    MaxActivationSelector()

Output selector that picks the output with the highest activation.
"""
struct MaxActivationSelector <: AbstractOutputSelector end
function (::MaxActivationSelector)(out::AbstractArray{T,N}) where {T,N}
    N < 2 && throw(BATCHDIM_MISSING)
    return vec(argmax(out; dims=1:(N - 1)))
end

"""
    IndexSelector(index)

Output selector that picks the output at the given index.
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
