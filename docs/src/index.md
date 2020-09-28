# Ontario COVID-19 Status

```@setup makefigs
!isdir("img") && mkdir("img")
using OntarioCOVID19, PyPlot
df = get_summary_data()

fig = plot_total_cases(df)
savefig(joinpath("img","status.svg"))
close(fig)

fig = plot_testing(df)
savefig(joinpath("img","testing.svg"))
close(fig)
```

![Ontario Cases Status](img/status.svg)

Data source: [https://data.ontario.ca/](https://data.ontario.ca/dataset?keywords_en=COVID-19)
