using GraphGraphviz
using Documenter

DocMeta.setdocmeta!(GraphGraphviz, :DocTestSetup, :(using GraphGraphviz); recursive=true)

makedocs(;
    modules=[GraphGraphviz],
    authors="Tor Erlend Fjelde <tor.erlend95@gmail.com> and contributors",
    repo="https://github.com/torfjelde/GraphGraphviz.jl/blob/{commit}{path}#{line}",
    sitename="GraphGraphviz.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://torfjelde.github.io/GraphGraphviz.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/torfjelde/GraphGraphviz.jl",
    devbranch="main",
)
