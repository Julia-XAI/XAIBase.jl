using Documenter
using XAIBase

makedocs(
    modules = [XAIBase],
    sitename = "XAIBase.jl",
    authors="Adrian Hill",
    format=Documenter.HTML(; prettyurls=get(ENV, "CI", "false") == "true", assets=String[]),
    pages=[
        "XAIBase Interface" => "index.md",
        "API Reference"     => "api.md",
    ],
    linkcheck=true,
    checkdocs=:exports, # only check docstrings in API reference if they are exported
)

deploydocs(; repo="github.com/Julia-XAI/XAIBase.jl")
