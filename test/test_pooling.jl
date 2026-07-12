using XAIBase
using Test

using XAIBase: pool

@testset "Pooling functions" begin
    # Attribution with signed values across the color-channel dimension (dims=3).
    # Channel values at pixel (1, 1, :, 1) are [3, -4], chosen so that norms are integers.
    A = zeros(1, 1, 2, 1)
    A[1, 1, 1, 1] = 3.0
    A[1, 1, 2, 1] = -4.0

    @testset "API" begin
        @test SumPool() isa SignedPooling
        @test MaxPool() isa SignedPooling
        @test L1Pool() isa PositivePooling
        @test NormPool() isa PositivePooling
        @test LInfPool() isa PositivePooling
        @test SquaredNormPool() isa PositivePooling

        # NoPooling is an identity pooling; treated as signed since its sign is unknown
        @test NoPooling() isa SignedPooling
        @test !(NoPooling() isa PositivePooling)

        for p in (SumPool(), MaxPool(), L1Pool(), NormPool(), LInfPool(), SquaredNormPool())
            @test p isa AbstractPooling
            # Pooling keeps the reduced dimension as a singleton
            @test size(pool(p, A, 3)) == (1, 1, 1, 1)
            # Callable syntax is equivalent to `pool`
            @test p(A, 3) == pool(p, A, 3)
        end
    end

    @testset "NoPooling is the identity" begin
        @test pool(NoPooling(), A, 3) === A       # returned unchanged, `dim` ignored
        @test NoPooling()(A, 3) === A
        @test pool(NoPooling(), A, 1) === A
    end

    @testset "Values" begin
        @test pool(SumPool(), A, 3)[] ≈ -1.0       # 3 + (-4)
        @test pool(MaxPool(), A, 3)[] ≈ 3.0        # max(3, -4)
        @test pool(L1Pool(), A, 3)[] ≈ 7.0         # |3| + |-4|
        @test pool(NormPool(), A, 3)[] ≈ 5.0         # √(3² + 4²)
        @test pool(LInfPool(), A, 3)[] ≈ 4.0       # max(|3|, |-4|)
        @test pool(SquaredNormPool(), A, 3)[] ≈ 25.0 # 3² + 4²

        # Non-negative poolings never return negative values
        @test all(≥(0), pool(L1Pool(), A, 3))
        @test all(≥(0), pool(NormPool(), A, 3))
        @test all(≥(0), pool(LInfPool(), A, 3))
        @test all(≥(0), pool(SquaredNormPool(), A, 3))
    end

    @testset "Pooling over other dimensions" begin
        B = reshape(collect(1.0:6.0), 2, 3) # pool a 2D feature matrix over dims=1
        @test pool(SumPool(), B, 1) ≈ sum(B; dims = 1)
        @test pool(NormPool(), B, 1) ≈ sqrt.(sum(abs2, B; dims = 1))
    end

    @testset "Explanation stores pooling" begin
        val = rand(2, 2, 3, 1)
        # Default pooling
        expl = Explanation(val, val, val, 1)
        @test expl.pooling isa NormPool
        # Pooling provided as a positional argument
        expl = Explanation(val, val, val, 1, SumPool())
        @test expl.pooling isa SumPool
        @test size(pool(expl.pooling, expl.val, 3)) == (2, 2, 1, 1)
        # Positional pooling alongside keyword `extras`
        expl = Explanation(val, val, val, 1, NoPooling(); extras = (; foo = 1))
        @test expl.pooling isa NoPooling
        @test expl.extras == (; foo = 1)
    end
end
