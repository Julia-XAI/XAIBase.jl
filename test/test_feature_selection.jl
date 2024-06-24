using XAIBase
using Test

@testset "Feature selectors" begin
    @testset "API" begin
        features = TopNFeatures(15)
        @test XAIBase.number_of_features(features) == 15
        features = IndexedFeatures(1:16...)
        @test XAIBase.number_of_features(features) == 16

        @test_throws DimensionMismatch (TopNFeatures(4))(rand(3, 5))
        @test_throws DimensionMismatch (TopNFeatures(4))(rand(5, 5, 3, 5))
    end
    @testset "2D input batches" begin
        R = [
            0.360588  0.180214
            0.721713  0.769733
            0.242516  0.918393
            0.736286  0.907605
        ]

        features = TopNFeatures(2)
        c1, c2 = features(R)
        @test R[c1[1]] ≈ [0.736286;;] # using ≈ for Julia 1.6 compatibility
        @test R[c1[2]] ≈ [0.918393;;]
        @test R[c2[1]] ≈ [0.721713;;]
        @test R[c2[2]] ≈ [0.907605;;]

        features = IndexedFeatures(3, 2)
        c1, c2 = features(R)
        @test R[c1[1]] ≈ [0.242516;;]
        @test R[c1[2]] ≈ [0.918393;;]
        @test R[c2[1]] ≈ [0.721713;;]
        @test R[c2[2]] ≈ [0.769733;;]
    end
    @testset "4D input batches" begin
        R = [
            0.520093 0.106578 0.943595 0.286332
            0.185124 0.624013 0.628282 0.068466
            0.988973 0.083252 0.833007 0.321842
            0.953506 0.687441 0.060545 0.502339
            0.521664 0.717311 0.698516 0.069322
            0.268384 0.920477 0.674791 0.748541
            0.663752 0.270196 0.904576 0.263793
            0.426357 0.090217 0.378728 0.543824
        ]
        R = reshape(R, 2, 2, 4, 2)

        # Check top activated features:

        # julia> sum(R; dims=(1, 2))
        # 1×1×4×2 Array{Float64, 4}:
        # [:, :, 1, 1] = 2.647696 # 1
        # [:, :, 2, 1] = 1.880157
        # [:, :, 3, 1] = 1.501284
        # [:, :, 4, 1] = 1.998201 # 2

        # [:, :, 1, 2] = 2.465429 # 2
        # [:, :, 2, 2] = 2.656611 # 1
        # [:, :, 3, 2] = 1.178979
        # [:, :, 4, 2] = 1.625480

        features = TopNFeatures(2)
        c1, c2 = features(R)
        @test R[c1[1]] == R[:, :, 1:1, 1:1]
        @test R[c2[1]] == R[:, :, 4:4, 1:1]
        @test R[c1[2]] == R[:, :, 2:2, 2:2]
        @test R[c2[2]] == R[:, :, 1:1, 2:2]

        features = IndexedFeatures(3, 2)
        c1, c2 = features(R)
        @test R[c1[1]] == R[:, :, 3:3, 1:1]
        @test R[c2[1]] == R[:, :, 2:2, 1:1]
        @test R[c1[2]] == R[:, :, 3:3, 2:2]
        @test R[c2[2]] == R[:, :, 2:2, 2:2]
    end
end
