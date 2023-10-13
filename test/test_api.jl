# Create dummy analyzer to test API and heatmapping
struct DummyAnalyzer <: AbstractXAIMethod end
function (method::DummyAnalyzer)(input, output_selector::AbstractNeuronSelector)
    output = input
    output_selection = output_selector(output)
    batchsize = size(input)[end]
    v = reshape(output[output_selection], :, batchsize)
    val = input .* v
    return Explanation(val, output, output_selection, :Dummy)
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
output_neuron = 2
val = [2 30; 4 25; 6 20]

expl = analyze(input, analyzer, output_neuron)
@test expl.val == val
@test isnothing(expl.extras)
expl = analyzer(input, output_neuron)
@test expl.val == val
