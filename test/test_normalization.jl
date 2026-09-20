using XAIBase
using Test

using XAIBase: normalize, normalization_bounds

@testset "Normalization functions" begin
    # Signed pooled attributions with extrema (-1, 3) and maximum absolute value 3
    A = [-1.0 0.0; 1.0 3.0]

    @testset "API" begin
        @test ExtremaNormalization() isa AbstractNormalization
        @test CenteredNormalization() isa AbstractNormalization

        for n in (ExtremaNormalization(), CenteredNormalization())
            B = normalize(n, A)
            @test size(B) == size(A)
            @test all(x -> 0 ≤ x ≤ 1, B)
            # Callable syntax is equivalent to `normalize`
            @test n(A) == B
            # Default bounds are computed via `normalization_bounds`
            bounds = normalization_bounds(n, A)
            @test normalize(n, A, bounds) == B
            @test n(A, bounds) == B
            # Normalization preserves the element type of floating-point arrays
            @test eltype(normalize(n, Float32.(A))) == Float32
        end
    end

    @testset "ExtremaNormalization" begin
        n = ExtremaNormalization()
        @test normalization_bounds(n, A) == (-1.0, 3.0)
        @test normalize(n, A) ≈ [0.0 0.25; 0.5 1.0]
    end

    @testset "CenteredNormalization" begin
        n = CenteredNormalization()
        @test normalization_bounds(n, A) == (-3.0, 3.0)
        @test normalize(n, A) ≈ [1 / 3 0.5; 2 / 3 1.0]
        # Zero attribution maps onto the midpoint 0.5
        @test normalize(n, A)[1, 2] == 0.5
    end

    @testset "Shared bounds across a batch" begin
        n = ExtremaNormalization()
        x1 = [0.0, 1.0]
        x2 = [0.0, 4.0]

        # Bounds can be computed over iterators, e.g. a flattened batch
        bounds = normalization_bounds(n, Iterators.flatten((x1, x2)))
        @test bounds == (0.0, 4.0)

        # Shared bounds keep samples comparable, per-sample bounds don't
        @test normalize(n, x1, bounds) ≈ [0.0, 0.25]
        @test normalize(n, x2, bounds) ≈ [0.0, 1.0]
        @test normalize(n, x1) ≈ [0.0, 1.0]
    end

    @testset "Explicit bounds clamp" begin
        n = ExtremaNormalization()
        @test normalize(n, [-1.0, 0.5, 2.0], (0.0, 1.0)) == [0.0, 0.5, 1.0]
        @test_throws ArgumentError normalize(n, A, (1.0, 0.0))
    end

    @testset "Degenerate value ranges" begin
        # Constant arrays map onto the midpoint 0.5
        @test normalize(ExtremaNormalization(), fill(2.0, 2, 2)) == fill(0.5, 2, 2)
        @test normalize(CenteredNormalization(), zeros(2, 2)) == fill(0.5, 2, 2)
        @test eltype(normalize(ExtremaNormalization(), fill(2.0f0, 2))) == Float32
    end

    @testset "default_normalization" begin
        # Non-negative poolings → sequential colormap → extrema normalization
        @test default_normalization(SumAbsPooling()) isa ExtremaNormalization
        @test default_normalization(AbsSumPooling()) isa ExtremaNormalization
        @test default_normalization(MaxAbsPooling()) isa ExtremaNormalization
        @test default_normalization(NormPooling()) isa ExtremaNormalization
        @test default_normalization(SquaredNormPooling()) isa ExtremaNormalization
        @test default_normalization(UnsignedNoPooling()) isa ExtremaNormalization

        # Signed poolings → diverging colormap → centered normalization
        @test default_normalization(SumPooling()) isa CenteredNormalization
        @test default_normalization(MaxPooling()) isa CenteredNormalization
        @test default_normalization(SignedNoPooling()) isa CenteredNormalization
    end

    @testset "Composition with pooling" begin
        # The full pool → normalize chain on a WHCN attribution with two pixels:
        # channel values [3, -4] and [1, 1] sum-pool to -1 and 2 respectively
        val = reshape([3.0, 1.0, -4.0, 1.0], 2, 1, 2, 1)
        attr = Attribution(val, val, val, 1, SumPooling())

        pooled = attr.pooling(attr.val, 3)
        @test pooled == reshape([-1.0, 2.0], 2, 1, 1, 1)

        n = default_normalization(attr.pooling)
        @test n isa CenteredNormalization
        # Maximum absolute value 2 maps (-2, 2) onto (0, 1)
        @test normalize(n, pooled) == reshape([0.25, 1.0], 2, 1, 1, 1)
    end
end
