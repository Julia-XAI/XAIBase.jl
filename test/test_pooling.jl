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
        @test SumAbsPooling() isa UnsignedPooling
        @test AbsSumPooling() isa UnsignedPooling
        @test MaxAbsPooling() isa UnsignedPooling
        @test NormPooling() isa UnsignedPooling
        @test SquaredNormPooling() isa UnsignedPooling

        # Identity poolings: SignedNoPooling makes no guarantee about its sign,
        # UnsignedNoPooling declares non-negative values
        @test SignedNoPooling() isa SignedPooling
        @test !(SignedNoPooling() isa UnsignedPooling)
        @test UnsignedNoPooling() isa UnsignedPooling
        @test !(UnsignedNoPooling() isa SignedPooling)

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
        for p in (SignedNoPooling(), UnsignedNoPooling())
            @test pool(p, A, 3) === A       # returned unchanged, `dims` ignored
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

    @testset "Attribution stores pooling" begin
        val = rand(2, 2, 3, 1)
        # Default pooling
        attr = Attribution(val, val, val, 1)
        @test attr.pooling isa NormPooling
        # Pooling provided as a positional argument
        attr = Attribution(val, val, val, 1, SumPooling())
        @test attr.pooling isa SumPooling
        @test size(pool(attr.pooling, attr.val, 3)) == (2, 2, 1, 1)
        # Positional pooling alongside keyword `extras`
        attr = Attribution(val, val, val, 1, SignedNoPooling(); extras = (; foo = 1))
        @test attr.pooling isa SignedNoPooling
        @test attr.extras == (; foo = 1)
    end
end
