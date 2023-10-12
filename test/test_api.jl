# Create dummy analyzer to test API and heatmapping
struct DummyAnalyzer <: AbstractXAIMethod end
function (method::DummyAnalyzer)(input, ns::AbstractNeuronSelector)
    output = input
    output_indices = ns(output)
    batchsize = size(input)[end]
    v = reshape(output[output_indices], :, batchsize)
    val = input .* v
    return Explanation(val, output, output_indices, :Dummy)
end

analyzer = DummyAnalyzer()
input = [1 6; 2 5; 3 4]

# Max activation
ns = XAIBase.MaxActivationSelector()
val = [3 36; 6 30; 9 24]

expl = analyze(input, analyzer)
@assert expl.val == val

# Ouput selection
output_neuron = 2
val = [2 30; 4 25; 6 20]

expl = analyze(input, analyzer, output_neuron)
@assert expl.val == val
@assert isnothing(expl.extras)
