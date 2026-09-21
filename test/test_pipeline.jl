using XAIBase
using Test

using XAIBase: AbstractTransform, Pipeline, compose

# Downstream packages define their own transforms, e.g. colormaps
struct DummyTransform <: AbstractTransform
    id::Int
end
struct DummyNormalization <: AbstractNormalization end

@testset "Pipelines" begin
    @testset "Supertypes" begin
        @test AbstractPooling <: AbstractTransform
        @test AbstractNormalization <: AbstractTransform
        @test Pipeline <: AbstractTransform
    end

    @testset "Composition" begin
        p = NormPooling()
        n = ExtremaNormalization()
        t = DummyTransform(1)

        # Poolings and normalizations can be composed directly
        @test p |> n == Pipeline((p, n))
        @test p |> n |> t == Pipeline((p, n, t))
        @test compose(p, n, t) == Pipeline((p, n, t))
        @test Pipeline(p, n, t) == Pipeline((p, n, t))

        # Single transforms aren't wrapped
        @test Pipeline(t) === t
        @test compose(t) === t

        # Nested pipelines are flattened
        pooled = p |> n
        dummies = t |> DummyTransform(2)
        @test pooled |> t == Pipeline((p, n, t))
        @test t |> pooled == Pipeline((t, p, n))
        @test pooled |> dummies == Pipeline((p, n, t, DummyTransform(2)))
    end

    @testset "Printing" begin
        pipe = SumPooling() |> CenteredNormalization()
        @test repr(pipe) == "Pipeline(\n  SumPooling(),\n  CenteredNormalization(),\n)"
    end

    @testset "Pooling and normalization pairing" begin
        issigned = XAIBase.issigned
        @test issigned(SumPooling())
        @test !issigned(NormPooling())
        @test issigned(CenteredNormalization())
        @test !issigned(ExtremaNormalization())
        @test issigned(BatchedNormalization(CenteredNormalization()))
        @test isnothing(issigned(DummyNormalization()))

        # Matching and unknown signs don't warn
        @test_logs NormPooling() |> ExtremaNormalization()
        @test_logs SumPooling() |> CenteredNormalization()
        @test_logs SumPooling() |> DummyNormalization()
        @test_logs DummyTransform(1) |> ExtremaNormalization()

        # Mismatched signs warn
        @test_logs (:warn, r"returns signed values") SumPooling() |> ExtremaNormalization()
        @test_logs (:warn, r"returns unsigned values") NormPooling() |>
            CenteredNormalization()
        @test_logs (:warn, r"returns signed values") SumPooling() |>
            DummyTransform(1) |>
            BatchedNormalization(ExtremaNormalization())
        @test_logs (:warn, r"returns signed values") SumPooling() |>
            (ExtremaNormalization() |> DummyTransform(1))
    end
end
