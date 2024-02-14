using XAIBase
using Test
using ReferenceTests
using Aqua
using JuliaFormatter

@testset "XAIBase.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(XAIBase; ambiguities=false)
    end
    @testset "JuliaFormatter.jl" begin
        @info "Running JuliaFormatter's code formatting tests."
        @test format(XAIBase; verbose=false, overwrite=false)
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
    @testset "Vision heatmaps" begin
        @info "Testing vision heatmaps..."
        include("test_heatmap.jl")
    end
    @testset "Text heatmaps" begin
        @info "Testing text heatmaps..."
        include("test_textheatmap.jl")
    end
end
