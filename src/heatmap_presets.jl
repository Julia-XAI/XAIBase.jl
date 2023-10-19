const HEATMAPPING_PRESETS = Dict{Symbol,NTuple{3,Symbol}}(
    # Analyzer          => (colorscheme,          reduce, rangescale)
    :LRP                => (:seismic, :sum, :centered), # attribution
    :CRP                => (:seismic, :sum, :centered), # attribution
    :InputTimesGradient => (:seismic, :sum, :centered), # attribution
    :Gradient           => (:grays, :norm, :extrema),  # gradient
)
const FALLBACK_HEATMAPPING_PRESET = (:seismic, :sum, :centered)

function get_heatmapping_preset(analyzer::Symbol)
    return get(HEATMAPPING_PRESETS, analyzer, FALLBACK_HEATMAPPING_PRESET)
end
