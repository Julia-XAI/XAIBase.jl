# Create dummy analyzer to test API and heatmapping
struct DummyAnalyzer <: AbstractXAIMethod end
function (method::DummyAnalyzer)(input, output_selector::AbstractNeuronSelector)
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
output_neuron = 2
val = [2 30; 4 25; 6 20]

expl = analyze(input, analyzer, output_neuron)
@test expl.val == val
@test isnothing(expl.extras)
expl = analyzer(input, output_neuron)
@test expl.val == val

# Ouput selection + add_batch_dim
expl = analyzer(input_vec, output_neuron; add_batch_dim=true)
@test expl.val == val[:, 1:1]

# Test direct heatmapping
input = rand(5, 5, 3, 1)

h1 = heatmap(analyze(input, analyzer))
h2 = heatmap(input, analyzer)
@test h1 == h2

h1 = heatmap(analyze(input, analyzer, 5))
h2 = heatmap(input, analyzer, 5)
@test h1 == h2

input = rand(5, 5, 3)

h1 = heatmap(analyze(input, analyzer; add_batch_dim=true))
h2 = heatmap(input, analyzer; add_batch_dim=true)
@test h1 == h2

h1 = heatmap(analyze(input, analyzer, 5; add_batch_dim=true))
h2 = heatmap(input, analyzer, 5; add_batch_dim=true)
@test h1 == h2
