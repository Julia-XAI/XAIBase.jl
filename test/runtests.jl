using XAIBase
using Test
using ReferenceTests
using Aqua

@testset "XAIBase.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(XAIBase; ambiguities=false)
    end
    @testset "API" begin
        @info "Testing API..."
        include("test_api.jl")
    end
    @testset "Neuron selection" begin
        @info "Testing neuron selection..."
        include("test_neuron_selection.jl")
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
