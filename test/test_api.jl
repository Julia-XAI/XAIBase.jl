using XAIBase
using Test

# Create dummy analyzer to test API
struct DummyAnalyzer <: AbstractXAIMethod end
function (method::DummyAnalyzer)(input, output_selector::AbstractOutputSelector)
    output = input
    output_selection = output_selector(output)
    batchsize = size(input)[end]
    v = reshape(output[output_selection], :, batchsize)
    val = input .* v
    return Explanation(val, output, output_selection, :Dummy, :attribution)
end

analyzer = DummyAnalyzer()
input = [1 6; 2 5; 3 4]

# Max activation
val = [3 36; 6 30; 9 24]

expl = analyze(input, analyzer)
@test expl.val == val
expl = analyzer(input)
@test expl.val == val

# Max activation + add_batch_dim
input_vec = [1, 2, 3]
expl = analyzer(input_vec; add_batch_dim=true)
@test expl.val == val[:, 1:1]

# Ouput selection
output_index = 2
val = [2 30; 4 25; 6 20]

expl = analyze(input, analyzer, output_index)
@test expl.val == val
@test isnothing(expl.extras)
expl = analyzer(input, output_index)
@test expl.val == val

# Ouput selection + add_batch_dim
expl = analyzer(input_vec, output_index; add_batch_dim=true)
@test expl.val == val[:, 1:1]
