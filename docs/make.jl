using XAIBase
using Documenter

DocMeta.setdocmeta!(XAIBase, :DocTestSetup, :(using XAIBase); recursive=true)

makedocs(;
    modules=[XAIBase],
    authors="Adrian Hill <gh@adrianhill.de>",
    repo="https://github.com/Julia-XAI/XAIBase.jl/blob/{commit}{path}#{line}",
    sitename="XAIBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Julia-XAI.github.io/XAIBase.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Julia-XAI/XAIBase.jl",
    devbranch="main",
)
