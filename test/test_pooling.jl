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
        @test SumPooling() isa SignedPooling
        @test MaxPooling() isa SignedPooling
        @test SumAbsPooling() isa PositivePooling
        @test AbsSumPooling() isa PositivePooling
        @test MaxAbsPooling() isa PositivePooling
        @test NormPooling() isa PositivePooling
        @test SquaredNormPooling() isa PositivePooling

        # Identity poolings: SignedNoPooling makes no guarantee about its sign,
        # PositiveNoPooling asserts non-negative values
        @test SignedNoPooling() isa SignedPooling
        @test !(SignedNoPooling() isa PositivePooling)
        @test PositiveNoPooling() isa PositivePooling
        @test !(PositiveNoPooling() isa SignedPooling)

        for p in (
                SumPooling(), MaxPooling(), SumAbsPooling(), AbsSumPooling(),
                MaxAbsPooling(), NormPooling(), SquaredNormPooling(),
            )
            @test p isa AbstractPooling
            # Pooling keeps the reduced dimension as a singleton
            @test size(pool(p, A, 3)) == (1, 1, 1, 1)
            # Callable syntax is equivalent to `pool`
            @test p(A, 3) == pool(p, A, 3)
        end
    end

    @testset "Identity poolings" begin
        for p in (SignedNoPooling(), PositiveNoPooling())
            @test pool(p, A, 3) === A       # returned unchanged, `dim` ignored
            @test p(A, 3) === A
            @test pool(p, A, 1) === A
        end
    end

    @testset "Values" begin
        @test pool(SumPooling(), A, 3)[] ≈ -1.0         # 3 + (-4)
        @test pool(MaxPooling(), A, 3)[] ≈ 3.0          # max(3, -4)
        @test pool(SumAbsPooling(), A, 3)[] ≈ 7.0       # |3| + |-4|
        @test pool(AbsSumPooling(), A, 3)[] ≈ 1.0       # |3 + (-4)|
        @test pool(MaxAbsPooling(), A, 3)[] ≈ 4.0       # max(|3|, |-4|)
        @test pool(NormPooling(), A, 3)[] ≈ 5.0         # √(3² + 4²)
        @test pool(SquaredNormPooling(), A, 3)[] ≈ 25.0 # 3² + 4²

        # Non-negative poolings never return negative values
        @test all(≥(0), pool(SumAbsPooling(), A, 3))
        @test all(≥(0), pool(AbsSumPooling(), A, 3))
        @test all(≥(0), pool(MaxAbsPooling(), A, 3))
        @test all(≥(0), pool(NormPooling(), A, 3))
        @test all(≥(0), pool(SquaredNormPooling(), A, 3))
    end

    @testset "Pooling over other dimensions" begin
        B = reshape(collect(1.0:6.0), 2, 3) # pool a 2D feature matrix over dims=1
        @test pool(SumPooling(), B, 1) ≈ sum(B; dims = 1)
        @test pool(NormPooling(), B, 1) ≈ sqrt.(sum(abs2, B; dims = 1))
    end

    @testset "Explanation stores pooling" begin
        val = rand(2, 2, 3, 1)
        # Default pooling
        expl = Explanation(val, val, val, 1)
        @test expl.pooling isa NormPooling
        # Pooling provided as a positional argument
        expl = Explanation(val, val, val, 1, SumPooling())
        @test expl.pooling isa SumPooling
        @test size(pool(expl.pooling, expl.val, 3)) == (2, 2, 1, 1)
        # Positional pooling alongside keyword `extras`
        expl = Explanation(val, val, val, 1, SignedNoPooling(); extras = (; foo = 1))
        @test expl.pooling isa SignedNoPooling
        @test expl.extras == (; foo = 1)
    end
end
