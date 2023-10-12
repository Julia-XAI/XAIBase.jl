using TextHeatmaps

val = output = [1 6; 2 5; 3 4]
text = [["Test", "Text", "Heatmap"], ["another", "dummy", "input"]]
neuron_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant
expl = Explanation(val, output, neuron_selection, :Gradient)
h1 = heatmap(expl, text)

expl = Explanation(val, output, neuron_selection, :LRP)
h2 = heatmap(expl, text)
