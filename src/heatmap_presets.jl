const HEATMAPPING_PRESETS = Dict{Symbol,NTuple{3,Symbol}}(
    # Analyzer          => (colorscheme,          reduce, rangescale)
    :LRP                => (:seismic, :sum, :centered), # attribution
    :CRP                => (:seismic, :sum, :centered), # attribution
    :InputTimesGradient => (:seismic, :sum, :centered), # attribution
    :Gradient           => (:grays, :norm, :extrema),  # gradient
)
