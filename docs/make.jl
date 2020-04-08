using Documenter, OntarioCOVID19, SparseArrays, PyPlot

DocMeta.setdocmeta!(OntarioCOVID19, :DocTestSetup, :(using OntarioCOVID19); recursive=true)

makedocs(
    sitename = "OntarioCOVID19",
    authors = "Jérémy Béjanin.",
    modules = [OntarioCOVID19],
    format = Documenter.HTML(prettyurls = false),
    linkcheck = true,
    clean = false,
    pages = [
        "Ontario COVID-19 Status" => "index.md",
        "Testing" => "testing.md",
    ]
)

deploydocs(
    repo = "github.com/jebej/OntarioCOVID19.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
