using WeekendRaytracer
using Documenter

DocMeta.setdocmeta!(WeekendRaytracer, :DocTestSetup, :(using WeekendRaytracer); recursive=true)

makedocs(;
    modules=[WeekendRaytracer],
    authors="Grant Hecht",
    repo="https://github.com/GrantHecht/WeekendRaytracer.jl/blob/{commit}{path}#{line}",
    sitename="WeekendRaytracer.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://GrantHecht.github.io/WeekendRaytracer.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/GrantHecht/WeekendRaytracer.jl",
    devbranch="main",
)
