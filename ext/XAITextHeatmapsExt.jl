module XAITextHeatmapsExt

using XAIBase, TextHeatmaps
import TextHeatmaps: heatmap

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
    _reduce, rangescale, colorscheme = get_heatmap_settings(expl; kwargs...)

    T = Vector{eltype(expl.val)}
    return [
        # heatmap(v, t; rangescale, colorscheme) for # TODO: add colorscheme
        heatmap(v, t; rangescale) for
        (v, t) in zip(eachcol(x), texts)
    ]
end

function get_heatmap_settings(expl::Explanation; kwargs...)
    colorscheme_preset, reduce_preset, rangescale_preset = XAIBase.HEATMAPPING_PRESETS[expl.analyzer]

    reduce = get(kwargs, :reduce, reduce_preset)
    rangescale = get(kwargs, :rangescale, rangescale_preset)
    colorscheme = get(kwargs, :colorscheme, colorscheme_preset)
    return reduce, rangescale, colorscheme
end

end # module
