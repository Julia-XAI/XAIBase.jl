module XAIVisionHeatmapsExt

using XAIBase, VisionHeatmaps
import VisionHeatmaps: heatmap

"""
    heatmap(explanation)

Visualize `Explanation` from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batchsize) for `explanation.val`.
"""
function heatmap(expl::Explanation; kwargs...)
    reduce, rangescale, colorscheme = get_vision_heatmap_settings(expl; kwargs...)
    return heatmap(expl.val; reduce, rangescale, colorscheme, kwargs...)
end

function get_vision_heatmap_settings(expl::Explanation; kwargs...)
    cs_preset, red_preset, rs_preset = XAIBase.get_heatmapping_preset(expl.analyzer)

    reduce = get(kwargs, :reduce, red_preset)
    rangescale = get(kwargs, :rangescale, rs_preset)
    colorscheme = get(kwargs, :colorscheme, cs_preset)
    return reduce, rangescale, colorscheme
end

end # module
