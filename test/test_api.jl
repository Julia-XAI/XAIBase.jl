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
    return Explanation(val, input, output, output_selection, :Dummy, :attribution)
end

analyzer = DummyAnalyzer()
input = [1 6; 2 5; 3 4]

# Max activation
val = [3 36; 6 30; 9 24]

expl = analyze(input, analyzer)
@test expl.val == val
expl = analyzer(input)
@test expl.val == val

# Ouput selection
output_index = 2
val = [2 30; 4 25; 6 20]

expl = analyze(input, analyzer, output_index)
@test expl.val == val
@test isnothing(expl.extras)
expl = analyzer(input, output_index)
@test expl.val == val

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
    return Explanation(val, input, output, output_selection, :AnyInput, :attribution)
end

analyzer = AnyInputAnalyzer()

input1 = (foo=1, bar=2) # NamedTuple
expl1 = analyze(input1, analyzer)
@test expl1.input isa NamedTuple

input2 = "Hello world" # String
expl2 = analyze(input2, analyzer)
@test expl2.input isa String
