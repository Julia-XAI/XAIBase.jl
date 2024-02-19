# XAIBase.jl
## Version `v3.0.0`
* ![BREAKING][badge-breaking] Remove heatmapping functionality. 
  Users are now required to manually load either 
  [VisionHeatmaps.jl](https://julia-xai.github.io/XAIDocs/VisionHeatmaps/stable/) or
  [TextHeatmaps.jl](https://julia-xai.github.io/XAIDocs/TextHeatmaps/stable/). ([#16][pr-16])

## Version `v2.0.0`
* ![BREAKING][badge-breaking] Rename `AbstractNeuronSelector` to `AbstractOutputSelector` ([#14][pr-14])
* ![Feature][badge-feature] Export output selectors ([#15][pr-15])
* ![Documentation][badge-docs] Add example implementations of XAI methods ([#13][pr-13])
* ![Documentation][badge-docs] Improved documentation of output and feature selectors ([#15][pr-15])

## Version `v1.3.0`
* ![Feature][badge-feature] Add feature selectors ([#12][pr-12])
* ![Documentation][badge-docs] Add documentation ([#11][pr-11])

## Version `v1.2.0`
* ![Feature][badge-feature] Add API for direct heatmapping ([#9][pr-9])

## Version `v1.1.1`
* ![Bugfix][badge-bugfix] Fix keyword argument `add_batch_dim` ([#8][pr-8])

## Version `v1.1.0`
This release makes VisionHeatmaps.jl and TextHeatmaps.jl strong dependencies of XAIBase ([#4][pr-4])
* ![Feature][badge-feature] Add `heatmap` preset field to `Explanation` struct ([#5][pr-5], [#6][pr-6])
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

[pr-16]: https://github.com/Julia-XAI/XAIBase.jl/pull/16
[pr-15]: https://github.com/Julia-XAI/XAIBase.jl/pull/15
[pr-14]: https://github.com/Julia-XAI/XAIBase.jl/pull/14
[pr-13]: https://github.com/Julia-XAI/XAIBase.jl/pull/13
[pr-12]: https://github.com/Julia-XAI/XAIBase.jl/pull/12
[pr-11]: https://github.com/Julia-XAI/XAIBase.jl/pull/11
[pr-9]: https://github.com/Julia-XAI/XAIBase.jl/pull/9
[pr-8]: https://github.com/Julia-XAI/XAIBase.jl/pull/8
[pr-6]: https://github.com/Julia-XAI/XAIBase.jl/pull/6
[pr-5]: https://github.com/Julia-XAI/XAIBase.jl/pull/5
[pr-4]: https://github.com/Julia-XAI/XAIBase.jl/pull/4

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg
[badge-docs]: https://img.shields.io/badge/docs-orange.svg