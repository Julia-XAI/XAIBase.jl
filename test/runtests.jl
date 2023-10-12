using XAIBase
using Test
using ReferenceTests
using Aqua

@testset "XAIBase.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        # Package extensions break Project.toml formatting tests on Julia 1.6
        # https://github.com/JuliaTesting/Aqua.jl/issues/105
        Aqua.test_all(XAIBase; ambiguities=false, project_toml_formatting=VERSION >= v"1.7")
    end
    @testset "API" begin
        @info "Testing API..."
        include("test_api.jl")
    end
    @testset "Neuron selection" begin
        @info "Testing neuron selection..."
        include("test_neuron_selection.jl")
    end
    @testset "TextHeatmaps" begin
        @info "Testing text heatmaps..."
        include("test_heatmaps_text.jl")
    end
end
