struct HeatmapConfig
    colorscheme::Symbol
    reduce::Symbol
    rangescale::Symbol
end

const DEFAULT_COLORSCHEME = :seismic
const DEFAULT_REDUCE = :sum
const DEFAULT_RANGESCALE = :centered
const DEFAULT_HEATMAP_PRESET = HeatmapConfig(
    DEFAULT_COLORSCHEME, DEFAULT_REDUCE, DEFAULT_RANGESCALE
)

const HEATMAP_PRESETS = Dict{Symbol,HeatmapConfig}(
    :attribution => HeatmapConfig(:seismic, :sum, :centered),
    :sensitivity => HeatmapConfig(:grays, :norm, :extrema),
    :cam         => HeatmapConfig(:jet, :sum, :extrema),
)

# Select HeatmapConfig preset based on heatmapping style in Explanation
function get_heatmapping_config(heatmap::Symbol)
    return get(HEATMAP_PRESETS, heatmap, DEFAULT_HEATMAP_PRESET)
end

# Override HeatmapConfig preset with keyword arguments
function get_heatmapping_config(expl::Explanation; kwargs...)
    c = get_heatmapping_config(expl.heatmap)

    colorscheme = get(kwargs, :colorscheme, c.colorscheme)
    rangescale  = get(kwargs, :rangescale, c.rangescale)
    reduce      = get(kwargs, :reduce, c.reduce)
    return HeatmapConfig(colorscheme, reduce, rangescale)
end

#=================#
# Vision Heatmaps #
#=================#

"""
    heatmap(explanation)

Visualize [`Explanation`](@ref) from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batchsize) for `explanation.val`.

## Keyword arguments
- `colorscheme::Union{ColorScheme,Symbol}`: color scheme from ColorSchemes.jl.
  Defaults to `:$DEFAULT_COLORSCHEME`.
- `reduce::Symbol`: Selects how color channels are reduced to a single number to apply a color scheme.
  The following methods can be selected, which are then applied over the color channels
  for each "pixel" in the array:
  - `:sum`: sum up color channels
  - `:norm`: compute 2-norm over the color channels
  - `:maxabs`: compute `maximum(abs, x)` over the color channels
  Defaults to `:$DEFAULT_REDUCE`.
- `rangescale::Symbol`: Selects how the color channel reduced heatmap is normalized
  before the color scheme is applied. Can be either `:extrema` or `:centered`.
  Defaults to `:$DEFAULT_RANGESCALE`.
- `process_batch::Bool`: When heatmapping a batch, setting `process_batch=true`
  will apply the `rangescale` normalization to the entire batch
  instead of computing it individually for each sample in the batch.
  Defaults to `false`.
- `permute::Bool`: Whether to flip W&H input channels. Default is `true`.
- `unpack_singleton::Bool`: If false, `heatmap` will always return a vector of images.
  When heatmapping a batch with a single sample, setting `unpack_singleton=true`
  will unpack the singleton vector and directly return the image. Defaults to `true`.
"""
function heatmap(expl::Explanation; kwargs...)
    c = get_heatmapping_config(expl; kwargs...)
    return VisionHeatmaps.heatmap(
        expl.val;
        colorscheme=c.colorscheme,
        reduce=c.reduce,
        rangescale=c.rangescale,
        kwargs...,
    )
end

"""
    heatmap(input, analyzer)

Compute an [`Explanation`](@ref) for a given `input` using the method `analyzer` and visualize it
as a vision heatmap.

Any additional arguments and keyword arguments are passed to the analyzer.
Refer to [`analyze`](@ref) for more information on available keyword arguments.

To customize the heatmapping style, first compute an explanation using [`analyze`](@ref)
and then call [`heatmap`](@ref) on the explanation.
"""
function heatmap(input, analyzer::AbstractXAIMethod, args...; kwargs...)
    expl = analyze(input, analyzer, args...; kwargs...)
    return heatmap(expl)
end

#===============#
# Text Heatmaps #
#===============#

"""
    heatmap(explanation, text)

Visualize [`Explanation`](@ref) from XAIBase as text heatmap.
Text should be a vector containing vectors of strings, one for each input in the batched explanation.

## Keyword arguments
- `colorscheme::Union{ColorScheme,Symbol}`: color scheme from ColorSchemes.jl.
  Defaults to `:$DEFAULT_COLORSCHEME`.
- `rangescale::Symbol`: selects how the color channel reduced heatmap is normalized
  before the color scheme is applied. Can be either `:extrema` or `:centered`.
  Defaults to `:$DEFAULT_RANGESCALE` for use with the default color scheme `:$DEFAULT_COLORSCHEME`.
"""
function heatmap(
    expl::Explanation, texts::AbstractVector{<:AbstractVector{<:AbstractString}}; kwargs...
)
    ndims(expl.val) != 2 && throw(
        ArgumentError(
            "To heatmap text, `explanation.val` must be 2D array of shape `(input_length, batchsize)`. Got array of shape $(size(x)) instead.",
        ),
    )
    batchsize = size(expl.val, 2)
    textsize = length(texts)
    batchsize != textsize && throw(
        ArgumentError("Batchsize $batchsize doesn't match number of texts $textsize.")
    )

    c = get_heatmapping_config(expl; kwargs...)
    return [
        TextHeatmaps.heatmap(v, t; colorscheme=c.colorscheme, rangescale=c.rangescale) for
        (v, t) in zip(eachcol(expl.val), texts)
    ]
end

function heatmap(expl::Explanation, text::AbstractVector{<:AbstractString}; kwargs...)
    return heatmap(expl, [text]; kwargs...)
end
