using TextHeatmaps

val = output = [1 6; 2 5; 3 4]
text = [["Test", "Text", "Heatmap"], ["another", "dummy", "input"]]
neuron_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant
expl = Explanation(val, output, neuron_selection, :Gradient)
h = TextHeatmaps.heatmap(expl, text)
@test_reference "references/Gradient1.txt" repr("text/plain", h[1])
@test_reference "references/Gradient2.txt" repr("text/plain", h[2])

expl = Explanation(val[:, 1:1], output[:, 1:1], neuron_selection[1], :Gradient)
h = TextHeatmaps.heatmap(expl, text[1])
@test_reference "references/Gradient1.txt" repr("text/plain", h)

expl = Explanation(val, output, neuron_selection, :LRP)
h = TextHeatmaps.heatmap(expl, text)
@test_reference "references/LRP1.txt" repr("text/plain", h[1])
@test_reference "references/LRP2.txt" repr("text/plain", h[2])

h = TextHeatmaps.heatmap(expl, text; rangescale=:extrema)
@test_reference "references/LRP1_extrema.txt" repr("text/plain", h[1])
@test_reference "references/LRP2_extrema.txt" repr("text/plain", h[2])
