module XAITextHeatmapsExt

using XAIBase, TextHeatmaps
import TextHeatmaps: heatmap

"""
    heatmap(explanation, text)

Visualize `Explanation` from XAIBase as text heatmap.
Text should be a vector containing vectors of strings, one for each input in the batched explanation.
"""
function heatmap(expl::Explanation, text::AbstractVector{<:AbstractString}; kwargs...)
    return only(heatmap(expl, [text]; kwargs...))
end

function heatmap(
    expl::Explanation, texts::AbstractVector{<:AbstractVector{<:AbstractString}}; kwargs...
)
    x = expl.val
    ndims(x) != 2 && throw(
        ArgumentError(
            "To heatmap text, `explanation.val` must be 2D array of shape `(input_length, batchsize)`. Got array of shape $(size(x)) instead.",
        ),
    )
    batchsize = size(x, 2)
    textsize = length(texts)
    batchsize != textsize && throw(
        ArgumentError("Batchsize $batchsize doesn't match number of texts $textsize.")
    )
    rangescale, colorscheme = get_text_heatmap_settings(expl; kwargs...)

    return [heatmap(v, t; rangescale, colorscheme) for (v, t) in zip(eachcol(x), texts)]
end

function get_text_heatmap_settings(expl::Explanation; kwargs...)
    cs_preset, _red_preset, rs_preset = XAIBase.get_heatmapping_preset(expl.analyzer)

    rangescale = get(kwargs, :rangescale, rs_preset)
    colorscheme = get(kwargs, :colorscheme, cs_preset)
    return rangescale, colorscheme
end

end # module
