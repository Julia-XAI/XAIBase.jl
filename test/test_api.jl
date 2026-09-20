using XAIBase
using Test

using XAIBase: AbstractXAIMethod, NotImplementedError
import XAIBase: call_analyzer

# Create dummy analyzer to test API
struct DummyAnalyzer <: AbstractXAIMethod end
function call_analyzer(
        input, ::DummyAnalyzer, output_selector::AbstractOutputSelector; kwargs...
    )
    output = input
    output_selection = output_selector(output)
    batchsize = size(input)[end]
    v = reshape(output[output_selection], :, batchsize)
    val = input .* v
    return Attribution(val, input, output, output_selection)
end

analyzer = DummyAnalyzer()
input = [1 6; 2 5; 3 4]

# Max activation
val = [3 36; 6 30; 9 24]

attr = analyze(input, analyzer)
@test attr.val == val
attr = analyzer(input)
@test attr.val == val

# Output selection
output_index = 2
val = [2 30; 4 25; 6 20]

attr = analyze(input, analyzer, output_index)
@test attr.val == val
@test isnothing(attr.extras)
attr = analyzer(input, output_index)
@test attr.val == val

# Dummy analyzer to test exceptions
struct EmptyAnalyzer <: AbstractXAIMethod end

analyzer = EmptyAnalyzer()
@test_throws NotImplementedError analyze(input, analyzer, output_index)

# Dummy analyzer to test "unusual" inputs
struct AnyInputAnalyzer <: AbstractXAIMethod end
function call_analyzer(
        input, ::AnyInputAnalyzer, output_selector::AbstractOutputSelector; kwargs...
    )
    output = 42
    output_selection = 42
    val = 42
    return Attribution(val, input, output, output_selection)
end

analyzer = AnyInputAnalyzer()

input1 = (foo = 1, bar = 2) # NamedTuple
expl1 = analyze(input1, analyzer)
@test expl1.input isa NamedTuple

input2 = "Hello world" # String
expl2 = analyze(input2, analyzer)
@test expl2.input isa String
