using XAIBase
using Test
using Aqua

@testset "XAIBase.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(XAIBase)
    end
    # Write your tests here.
end
