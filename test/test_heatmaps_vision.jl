using VisionHeatmaps

# NOTE: Heatmapping assumes Flux's WHCN convention (width, height, color channels, batch size).
# Single input
shape = (2, 2, 3, 1)
val = output = reshape(collect(Float32, 1:prod(shape)), shape)
neuron_selection = [CartesianIndex(1, 2)] # irrelevant
expl = Explanation(val, output, [neuron_selection], :LRP)

# Batch
shape = (2, 2, 3, 2)
val = output = reshape(collect(Float32, 1:prod(shape)), shape)
neuron_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant
expl_batch = Explanation(val, output, neuron_selection, :LRP)

reducers = [:sum, :maxabs, :norm]
rangescales = [:extrema, :centered]
for r in reducers
    for n in rangescales
        local h = VisionHeatmaps.heatmap(expl; reduce=r, rangescale=n)
        @test_reference "references/heatmaps/reduce_$(r)_rangescale_$(n).txt" h

        local h = VisionHeatmaps.heatmap(expl_batch; reduce=r, rangescale=n)
        @test_reference "references/heatmaps/reduce_$(r)_rangescale_$(n).txt" h[1]
        @test_reference "references/heatmaps/reduce_$(r)_rangescale_$(n)2.txt" h[2]
    end
end

h1 = VisionHeatmaps.heatmap(expl_batch)
h2 = VisionHeatmaps.heatmap(expl_batch; process_batch=true)
@test_reference "references/heatmaps/process_batch_false.txt" h1
@test_reference "references/heatmaps/process_batch_true.txt" h2
