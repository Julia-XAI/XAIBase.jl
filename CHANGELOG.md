# XAIBase.jl
## Version `v5.2.0`
* ![Feature][badge-feature] Add composable transforms for downstream packages like VisionHeatmaps.jl and TextHeatmaps.jl ([#29]):
  * `AbstractTransform` is the new supertype of `AbstractPooling` and `AbstractNormalization`
  * transforms are composed into a `Pipeline` using `|>`, e.g. `NormPooling() |> ExtremaNormalization()`
  * `AbstractTransform` and `Pipeline` are not exported to avoid name clashes
  * composing a pooling function with a normalization function of a different sign emits a warning,
    e.g. `SumPooling() |> ExtremaNormalization()`.
    The unexported `XAIBase.issigned` returns the sign of pooling and normalization functions
* ![Feature][badge-feature] Add batch support for downstream packages ([#29]):
  * `Batch(A; dims = ndims(A))` marks an array as a batch of samples along dimension `dims`
  * `eachsample` iterates over the samples in a batch, `mapsamples` applies a function to each sample and stacks the results
  * normalization functions normalize batches sample by sample
  * `BatchedNormalization(normalization)` normalizes the whole batch at once, making heatmaps comparable across samples
  * `pool` accepts batches and updates their batch dimension
* ![Bugfix][badge-bugfix] `pool` drops the pooled dimension instead of keeping it as a singleton, e.g. an array of size `(W, H, C, N)` is reduced to size `(W, H, N)`. Identity poolings `SignedNoPooling` and `UnsignedNoPooling` require a singleton feature dimension ([#29])
  * `Batch`, `eachsample` and `mapsamples` are not exported to avoid name clashes
* ![Maintenance][badge-maintenance] Require Julia `v1.10` (LTS) or newer ([#29])

## Version `v5.1.0`
* ![Feature][badge-feature] Add `XAIBase.test_interface(method, input; output_selection)`, a helper for method packages to check that a method conforms to the XAIBase interface: `analyze` returns an `Attribution`, the batch dimension of `val`/`input`/`output` is consistent, `output_selection` is a `Vector{<:CartesianIndex}` with one entry per sample, and `pooling` is an `AbstractPooling`. It adds no `Test` dependency, throwing an `InterfaceError` on a violated invariant and returning `true` otherwise ([#28])

## Version `v5.0.0`
* ![BREAKING][badge-breaking] Replace the `Explanation` result struct with `Attribution` ([#25]):
  * remove the `analyzer::Symbol` and `heatmap::Symbol` fields
  * add a `pooling` field, an optional positional argument defaulting to `NormPooling()`
* ![Feature][badge-feature] Add attribution pooling functions, fieldless subtypes of `AbstractPooling`, applied via `pool(pooling, A, dims)` or the equivalent callable syntax `pooling(A, dims)` ([#25]):
  * `SignedPooling`, with signed output: `SumPooling`, `MaxPooling`
  * `UnsignedPooling`, with non-negative output: `SumAbsPooling`, `AbsSumPooling`, `MaxAbsPooling`, `NormPooling`, `SquaredNormPooling`
  * identity poolings that skip the reduction: `SignedNoPooling` (unknown sign) and `UnsignedNoPooling` (non-negative, e.g. for Grad-CAM)
* ![Feature][badge-feature] Add normalization functions, fieldless subtypes of `AbstractNormalization`, that linearly rescale pooled attributions onto the unit interval `[0, 1]` ([#25]):
  * these are applied via `XAIBase.normalize(normalization, A[, bounds])` (unexported to avoid clashes with LinearAlgebra)
    or the equivalent callable syntax `normalization(A)`
  * `ExtremaNormalization` maps `(minimum(A), maximum(A))` onto `[0, 1]`
  * `CenteredNormalization` maps `(-maximum(abs, A), maximum(abs, A))` onto `[0, 1]`, mapping zero onto the midpoint `0.5`
  * `default_normalization(pooling)` returns the matching normalization for a pooling function
  * `normalization_bounds(normalization, A)` exposes the value range mapped onto `[0, 1]`; precomputing it over a batch normalizes all samples to a shared range for comparable heatmaps

## Version `v4.1.0`
* ![Feature][badge-feature] Refactor `IndexSelector` to support batches ([#22])
* ![Maintenance][badge-maintenance] Format with Runic ([#22])

## Version `v4.0.0`
* ![BREAKING][badge-breaking] Implementing new analyzers now requires a `call_analyzer` method instead of making the analyzer struct callable. This helps with type stability ([#20])
* ![BREAKING][badge-breaking] Add `input` field to `Explanation` struct
* ![BREAKING][badge-breaking] Remove `analyze` keyword-argument `add_batch_dim`, which made the assumption of array inputs ([#20])
* ![Feature][badge-feature] Remove type annotations that restricted `analyze` to `AbstractArray` inputs ([#20])
* ![Maintenance][badge-maintenance] XAIBase is now fully type stable and tested with JET.jl ([#20])
* ![Maintenance][badge-maintenance] Modularize tests ([#17])

## Version `v3.0.0`
* ![BREAKING][badge-breaking] Remove heatmapping functionality.
  Users are now required to manually load either
  [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/) or
  [TextHeatmaps.jl](https://julia-xai.github.io/XAIDocs/TextHeatmaps/stable/). ([#16])

## Version `v2.0.0`
* ![BREAKING][badge-breaking] Rename `AbstractNeuronSelector` to `AbstractOutputSelector` ([#14])
* ![Feature][badge-feature] Export output selectors ([#15])
* ![Documentation][badge-docs] Add example implementations of XAI methods ([#13])
* ![Documentation][badge-docs] Improved documentation of output and feature selectors ([#15])

## Version `v1.3.0`
* ![Feature][badge-feature] Add feature selectors ([#12])
* ![Documentation][badge-docs] Add documentation ([#11])

## Version `v1.2.0`
* ![Feature][badge-feature] Add API for direct heatmapping ([#9])

## Version `v1.1.1`
* ![Bugfix][badge-bugfix] Fix keyword argument `add_batch_dim` ([#8])

## Version `v1.1.0`
This release makes VisionHeatmaps.jl and TextHeatmaps.jl strong dependencies of XAIBase ([#4])
* ![Feature][badge-feature] Add `heatmap` preset field to `Explanation` struct ([#5], [#6])
* ![Feature][badge-feature] Add heatmapping preset for CAM methods ([5658de9](https://github.com/Julia-XAI/XAIBase.jl/commit/5658de9))

## Version `v1.0.0`
* Initial release

<!--
# Badges
![BREAKING][badge-breaking]
![Deprecation][badge-deprecation]
![Feature][badge-feature]
![Enhancement][badge-enhancement]
![Bugfix][badge-bugfix]
![Experimental][badge-experimental]
![Maintenance][badge-maintenance]
![Documentation][badge-docs]
-->

[#29]: https://github.com/Julia-XAI/XAIBase.jl/pull/29
[#28]: https://github.com/Julia-XAI/XAIBase.jl/pull/28
[#25]: https://github.com/Julia-XAI/XAIBase.jl/pull/25
[#22]: https://github.com/Julia-XAI/XAIBase.jl/pull/22
[#20]: https://github.com/Julia-XAI/XAIBase.jl/pull/20
[#17]: https://github.com/Julia-XAI/XAIBase.jl/pull/17
[#16]: https://github.com/Julia-XAI/XAIBase.jl/pull/16
[#15]: https://github.com/Julia-XAI/XAIBase.jl/pull/15
[#14]: https://github.com/Julia-XAI/XAIBase.jl/pull/14
[#13]: https://github.com/Julia-XAI/XAIBase.jl/pull/13
[#12]: https://github.com/Julia-XAI/XAIBase.jl/pull/12
[#11]: https://github.com/Julia-XAI/XAIBase.jl/pull/11
[#9]: https://github.com/Julia-XAI/XAIBase.jl/pull/9
[#8]: https://github.com/Julia-XAI/XAIBase.jl/pull/8
[#6]: https://github.com/Julia-XAI/XAIBase.jl/pull/6
[#5]: https://github.com/Julia-XAI/XAIBase.jl/pull/5
[#4]: https://github.com/Julia-XAI/XAIBase.jl/pull/4

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg
[badge-docs]: https://img.shields.io/badge/docs-orange.svg
