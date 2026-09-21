using XAIBase
using Test

using XAIBase: Batch, eachsample, mapsamples, normalize

A = reshape(collect(Float32, 1:24), 2, 3, 4)

@testset "Batch" begin
    b = Batch(A)
    @test b.val === A
    @test b.dims == 3
    @test Batch(A; dims = 1).dims == 1
    @test Batch(A) == Batch(copy(A))
    @test Batch(A) != Batch(A; dims = 2)
    @test_throws ArgumentError Batch(A; dims = 0)
    @test_throws ArgumentError Batch(A; dims = 4)

    @test collect(eachsample(b)) == [A[:, :, i] for i in 1:4]
    @test collect(eachsample(Batch(A; dims = 1))) == [A[i, :, :] for i in 1:2]
end

@testset "mapsamples" begin
    # Rank-preserving functions
    @test mapsamples(x -> 2x, Batch(A)) == Batch(2A)
    @test mapsamples(x -> 2x, Batch(A; dims = 1)) == Batch(2A; dims = 1)

    # A batch dimension that was last remains last
    b = mapsamples(x -> sum(x; dims = 1)[1, :], Batch(A))
    @test b == Batch(dropdims(sum(A; dims = 1); dims = 1))
    @test b.dims == 2

    # Otherwise, the batch dimension keeps its index
    b = mapsamples(x -> sum(x; dims = 2)[:, 1], Batch(A; dims = 1))
    @test b == Batch(dropdims(sum(A; dims = 3); dims = 3); dims = 1)

    # Result types are promoted
    b = mapsamples(x -> x[1] == 1 ? Int.(x) : x, Batch(A))
    @test eltype(b.val) == Float32

    # Multiple batches are mapped over pairwise
    B = 10 .* A
    @test mapsamples(+, Batch(A), Batch(B)) == Batch(A + B)
    @test mapsamples(+, Batch(A), Batch(B; dims = 3)) == Batch(A + B)
    @test_throws DimensionMismatch mapsamples(+, Batch(A), Batch(A; dims = 1))

    # Results need to have matching sizes
    @test_throws DimensionMismatch mapsamples(x -> x[1] == 1 ? x : x[:, 1:2], Batch(A))
end

@testset "Normalization" begin
    B = cat(A[:, :, 1:2], -3 .* A[:, :, 3:4]; dims = 3)
    for n in (ExtremaNormalization(), CenteredNormalization())
        # Batches are normalized sample by sample by default
        b = normalize(n, Batch(B))
        @test b == Batch(cat([normalize(n, x) for x in eachslice(B; dims = 3)]...; dims = 3))
        @test n(Batch(B)) == b

        # Precomputed bounds are shared across the batch
        bounds = normalization_bounds(n, B)
        @test normalize(n, Batch(B), bounds) == Batch(normalize(n, B, bounds))
        @test n(Batch(B), bounds) == Batch(normalize(n, B, bounds))

        # BatchedNormalization normalizes the whole batch at once
        bn = BatchedNormalization(n)
        @test bn isa AbstractNormalization
        @test normalization_bounds(bn, B) == bounds
        @test normalize(bn, Batch(B)) == Batch(normalize(n, B))
        @test bn(Batch(B)) == Batch(normalize(n, B))
        @test normalize(bn, Batch(B)) != normalize(n, Batch(B))

        # On single samples, it behaves like the wrapped normalization
        @test bn(A) == n(A)
    end

    bn = BatchedNormalization(ExtremaNormalization())
    @test repr(bn) == "BatchedNormalization(ExtremaNormalization())"
    @test NormPooling() |> bn isa XAIBase.Pipeline
end
