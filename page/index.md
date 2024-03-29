```julia:figsetup
#hideall
using OntarioCOVID19
p1,p2,p3,p4,p5,p6 = plot_all_plotly()
pv1,pv2 = plot_vaccination_data()
nothing
```

<!-- Total -->
\begin{:section, title="Total Cases", name="Total"}
```julia:fig1
plotlyplot(p1) #hide
```
\textoutput{fig1}
\end{:section}

<!-- DailyNew -->
\begin{:section, title="Daily New Cases", name="Daily New"}
```julia:fig2
plotlyplot(p2) #hide
```
\textoutput{fig2}
\end{:section}

<!-- Hospitalized -->
\begin{:section, title="Hospitalized Cases", name="Hospitalized"}
```julia:fig3
plotlyplot(p3) #hide
```
\textoutput{fig3}
\end{:section}

<!-- Tests -->
\begin{:section, title="Total Tests", name="Tests"}
```julia:fig4
plotlyplot(p4) #hide
```
\textoutput{fig4}
\end{:section}

<!-- Positivity -->
\begin{:section, title="Positivity Rate", name="Positivity"}
```julia:fig5
plotlyplot(p5) #hide
```
\textoutput{fig5}
\end{:section}

<!-- Daily Tests -->
\begin{:section, title="Daily Tests", name="Daily Tests"}
```julia:fig6
plotlyplot(p6) #hide
```
\textoutput{fig6}
\end{:section}

<!-- Total Vaccinated -->
\begin{:section, title="Vaccinations", name="Vaccinations"}
```julia:fig7
plotlyplot(pv1) #hide
```
\textoutput{fig7}
\end{:section}

<!-- Daily Doses -->
\begin{:section, title="Daily Doses Administered", name="Daily Doses"}
```julia:fig8
plotlyplot(pv2) #hide
```
\textoutput{fig8}
\end{:section}

<!-- Data Source -->
\begin{:section, title="Data Source", name="Data"}
```julia:updateddate
print(now()) #hide
```
Last updated: \textoutput{updateddate}

All data is gathered from the Ontario Data Catalogue: [https://data.ontario.ca/](https://data.ontario.ca/dataset?keywords_en=COVID-19)
\end{:section}
