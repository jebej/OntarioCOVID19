# Ontario COVID-19 Status

```@setup makefigs
!isdir("img") && mkdir("img")
using OntarioCOVID19, PyPlot
plot_total_cases()
savefig(joinpath("img","status.svg"))
close()
```

![Ontario Cases Status](img/status.svg)

Data source: [https://data.ontario.ca/](https://data.ontario.ca/dataset?keywords_en=COVID-19)
