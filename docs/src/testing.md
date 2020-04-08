# Ontario Testing

```@setup makefigs
!isdir("img") && mkdir("img")
using OntarioCOVID19, PyPlot
plot_testing()
savefig(joinpath("img","testing.svg"))
close()
```

![Ontario Testing](img/testing.svg)

Data source: [https://data.ontario.ca/](https://data.ontario.ca/dataset?keywords_en=COVID-19)
