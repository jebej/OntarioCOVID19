module OntarioCOVID19

using HTTP, CSV, DataFrames, Dates, PlotlyBase
export plot_all_plotly, plotlyplot

# show plots in static HTML
function plotlyplot(p::Plot)
    println("""
    ~~~
    <div id="$(p.divid)" style="width:100%;height:500px;"></div>
    <script>
      var plot_json = $(json(p));
      Plotly.newPlot("$(p.divid)", plot_json.data, plot_json.layout, {responsive: true, displaylogo: false});
    </script>
    ~~~
    """)
end

function get_summary_data()
    url = "https://data.ontario.ca/dataset/f4f86e54-872d-43f8-8a86-3892fd3cb5e6/resource/ed270bb8-340b-41f9-a7c6-e8ef587e6d11/download/covidtesting.csv"
    bytes = Vector{UInt8}(replace(String(HTTP.get(url).body),".0"=>""))
    return CSV.File(bytes; normalizenames=true) |> DataFrame
end
end

function plot_all_plotly()
    # download data
    df = get_summary_data()::DataFrame
    df = dropmissing(df, :Total_Cases, disallowmissing=true)::DataFrame

    # cases
    date = df.Reported_Date::Vector{Date}
    total_positive = df.Total_Cases::Vector{Int}
    daily_positive = diff([0;total_positive])
    active = coalesce.(df.Confirmed_Positive,0)::Vector{Int}
    recovered = coalesce.(df.Resolved,0)::Vector{Int}
    deceased = coalesce.(df.Deaths,0)::Vector{Int}
    deceased = coalesce.(df.Deaths,0)::Vector{Int}
    ventilator = coalesce.(df.Number_of_patients_in_ICU_on_a_ventilator_with_COVID_19,0)::Vector{Int}
    icu = coalesce.(df.Number_of_patients_in_ICU_with_COVID_19,0)::Vector{Int}
    hospitalized = coalesce.(df.Number_of_patients_hospitalized_with_COVID_19,0)::Vector{Int}

    tests = coalesce.(df.Total_patients_approved_for_testing_as_of_Reporting_Date,0)::Vector{Int}
    investigating = coalesce.(df.Under_Investigation,0)::Vector{Int}
    presumed_pos = coalesce.(df.Presumptive_Positive,0)::Vector{Int}
    presumed_neg = coalesce.(df.Presumptive_Negative,0)::Vector{Int}

    investigating .+= presumed_pos .+ presumed_neg
    negative = max.(tests .- total_positive .- investigating, 0) # don't use confirmed neg col since it's not updated

    daily_total = diff([0; total_positive .+ negative .+ investigating])

    positivity = max.(0,daily_positive./daily_total.*100)

    # plot
    layout_options = (xaxis_range=[date[18],date[end]+Day(1)], xaxis_title="Date", legend_xanchor="left", legend_x=0.01, paper_bgcolor="rgba(255,255,255,0)", plot_bgcolor="rgba(255,255,255,0)", margin_l=50, margin_r=50, margin_t=50, margin_b=50)

    t1 = bar(x=date,y=active,name="Active")
    t2 = bar(x=date,y=recovered,name="Recovered")
    t3 = bar(x=date,y=deceased,name="Deceased")
    p1 = Plot([t1,t2,t3], Layout(yaxis_title="Cases",barmode="stack";layout_options...))

    t1 = bar(x=date,y=daily_positive,name="Daily")
    t2 = scatter(x=date[7:end],y=moving_average(daily_positive,7),name="7-Day Average")
    p2 = Plot([t1,t2], Layout(yaxis_title="New Cases",barmode="stack";layout_options...))

    t1 = bar(x=date,y=hospitalized.-icu,name="Hospitalized, not in ICU")
    t2 = bar(x=date,y=icu.-ventilator,name="ICU without ventilator")
    t3 = bar(x=date,y=ventilator,name="On a ventilator")
    p3 = Plot([t1,t2,t3], Layout(yaxis_title="Hospitalized Cases",barmode="stack";layout_options...))

    t1 = bar(x=date,y=negative,name="Negative")
    t2 = bar(x=date,y=investigating,name="Pending")
    t3 = bar(x=date,y=total_positive,name="Positive")
    p4 = Plot([t1,t2,t3], Layout(yaxis_title="Tests",barmode="stack";layout_options...))

    t1 = bar(x=date,y=positivity,name="Daily")
    t2 = scatter(x=date[7:end],y=moving_average(positivity,7),name="7-Day Average")
    p5 = Plot([t1,t2], Layout(yaxis_title="Positivity Rate (%)";layout_options...))

    t1 = bar(x=date,y=daily_total,name="Daily")
    t2 = scatter(x=date[7:end],y=moving_average(daily_total,7),name="7-Day Average")
    p6 = Plot([t1,t2], Layout(yaxis_title="Daily Tests";layout_options...))

    return p1, p2, p3, p4, p5, p6
end

# backward-looking moving average
moving_average(vs,n) = [sum(@view vs[i-n+1:i])/n for i in n:length(vs)]

end # module
