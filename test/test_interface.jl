using XAIBase
using Test

using XAIBase: AbstractXAIMethod, InterfaceError
import XAIBase: call_analyzer

# Minimal conforming analyzer: returns the input as its attribution,
# with the default pooling.
struct InterfaceAnalyzer <: AbstractXAIMethod end
function call_analyzer(input, ::InterfaceAnalyzer, output_selector::AbstractOutputSelector; kwargs...)
    output = reshape(input, :, size(input)[end])
    output_selection = output_selector(output)
    return Attribution(input, input, output, output_selection)
end

# Conforming analyzer that sets a non-default pooling.
struct PooledAnalyzer <: AbstractXAIMethod end
function call_analyzer(input, ::PooledAnalyzer, output_selector::AbstractOutputSelector; kwargs...)
    output = reshape(input, :, size(input)[end])
    output_selection = output_selector(output)
    return Attribution(input, input, output, output_selection, SumPooling())
end

@testset "Conforming analyzers" begin
    @test XAIBase.test_interface(InterfaceAnalyzer(), rand(4, 2))                     # matrix input
    @test XAIBase.test_interface(InterfaceAnalyzer(), rand(Float32, 8, 8, 3, 2))      # WHCN input
    @test XAIBase.test_interface(InterfaceAnalyzer(), rand(4, 3); output_selection = 2)
    @test XAIBase.test_interface(InterfaceAnalyzer(), rand(Float32, 8, 8, 3, 1))      # single-sample batch
    @test XAIBase.test_interface(PooledAnalyzer(), rand(Float32, 8, 8, 3, 2))         # custom pooling
end

# Analyzer whose attribution has a batch dimension inconsistent with the input.
struct WrongBatchAnalyzer <: AbstractXAIMethod end
function call_analyzer(input, ::WrongBatchAnalyzer, output_selector::AbstractOutputSelector; kwargs...)
    output = reshape(input, :, size(input)[end])
    output_selection = output_selector(output)
    val = input[:, :, :, 1:1] # drops the batch dimension
    return Attribution(val, input, output, output_selection)
end

@testset "Non-conforming analyzers" begin
    @test_throws InterfaceError XAIBase.test_interface(WrongBatchAnalyzer(), rand(Float32, 8, 8, 3, 2))
end
