using XAIBase
using Test

using ReferenceTests

@testset "XAIBase.jl" begin
    @testset verbose = true "Linting" begin
        @info "Running linting tests..."
        include("linting.jl")
    end

    @testset "API" begin
        @info "Testing API..."
        include("test_api.jl")
    end
    @testset "Output selection" begin
        @info "Testing output selection..."
        include("test_output_selection.jl")
    end
    @testset "Feature selection" begin
        @info "Testing feature selection..."
        include("test_feature_selection.jl")
    end
end
