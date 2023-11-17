# Test deprecation warnings
shape = (2, 2, 3, 1)
val = output = reshape(collect(Float32, 1:prod(shape)), shape)
neuron_selection = [CartesianIndex(1, 2)] # irrelevant
@test_logs (:warn,) expl = Explanation(val, output, [neuron_selection], :LRP)
@test_logs (:warn,) expl = Explanation(val, output, [neuron_selection], :LRP, nothing)
