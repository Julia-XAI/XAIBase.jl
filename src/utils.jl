"""
    batch_dim_view(A)

Return a view onto the array `A` that contains an extra singleton batch dimension at the end.
This avoids allocating a new array.

## Example
```juliarepl
julia> A = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> batch_dim_view(A)
2×2×1 view(::Array{Int64, 3}, 1:2, 1:2, :) with eltype Int64:
[:, :, 1] =
 1  2
 3  4
```
"""
batch_dim_view(A::AbstractArray{T,N}) where {T,N} = view(A, ntuple(Returns(:), N + 1)...)
