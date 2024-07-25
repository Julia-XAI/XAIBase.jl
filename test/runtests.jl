using XAIBase
using Test

using JuliaFormatter
using Aqua
using JuliaFormatter
using Aqua
using JET
using ReferenceTests

@testset "XAIBase.jl" begin
    if VERSION >= v"1.10"
        @info "Testing formalities..."
        @testset "Code formatting" begin
            @info "- running JuliaFormatter code formatting tests..."
            @test JuliaFormatter.format(XAIBase; verbose=false, overwrite=false)
        end
        @testset "Aqua.jl" begin
            @info "- running Aqua.jl tests. These might print warnings from dependencies..."
            Aqua.test_all(XAIBase; ambiguities=false)
        end
        @testset "JET.jl" begin
            @info "- running JET.jl type stability tests..."
            JET.test_package(XAIBase; target_defined_modules=true)
        end
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
