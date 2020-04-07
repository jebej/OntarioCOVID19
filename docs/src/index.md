# Ontario COVID-19 Status

```@setup makefigs
!isdir("img") && mkdir("img")
using OntarioCOVID19, PyPlot
plot_total_cases();
savefig(joinpath("img","status.svg"))
```

![Ontario Cases Status](img/status.svg)
