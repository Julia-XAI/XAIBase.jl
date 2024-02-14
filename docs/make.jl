using Documenter
using XAIBase

makedocs(;
    modules  = [XAIBase],
    sitename = "XAIBase.jl",
    authors  = "Adrian Hill",
    format   = Documenter.HTML(; prettyurls=get(ENV, "CI", "false") == "true", assets=String[]),
    #! format: off
    pages = [
        "XAIBase Interface"       => "index.md",
        "Example Implementations" => "examples.md",
        "API Reference"           => "api.md"
    ],
    #! format: on
    linkcheck = true,
    checkdocs = :exports, # only check docstrings in API reference if they are exported
)

deploydocs(; repo="github.com/Julia-XAI/XAIBase.jl")
