module OntarioCOVID19

using HTTP, CSV, DataFrames, Dates, PlotlyBase
export plot_all_plotly, plot_vaccination_data, plotlyplot

# show plots in static HTML
function plotlyplot(p::Plot)
    println("""
    ~~~
    <div id="$(p.divid)" style="width:100%;height:500px;"></div>
    <script>
      var plot_json = $(json(p));
      var config = {responsive: true, displaylogo: false, toImageButtonOptions: {filename:'ontario-covid19',scale:2}};
      Plotly.newPlot("$(p.divid)", plot_json.data, plot_json.layout, config);
    </script>
    ~~~
    """)
end

function get_summary_data()
    url = "https://data.ontario.ca/dataset/f4f86e54-872d-43f8-8a86-3892fd3cb5e6/resource/ed270bb8-340b-41f9-a7c6-e8ef587e6d11/download/covidtesting.csv"
    bytes = Vector{UInt8}(replace(String(HTTP.get(url).body),".0"=>""))
    return CSV.File(bytes; normalizenames=true) |> DataFrame
end

function get_vaccine_data()
    url = "https://data.ontario.ca/dataset/752ce2b7-c15a-4965-a3dc-397bf405e7cc/resource/8a89caa9-511c-4568-af89-7f2174b4378c/download/vaccine_doses.csv"
    df = CSV.File(HTTP.get(url).body; normalizenames=true) |> DataFrame
    return df
end

function plot_vaccination_data()
    # vaccination data
    df = OntarioCOVID19.get_vaccine_data()::DataFrame
    df = dropmissing(df, :total_doses_administered, disallowmissing=true)::DataFrame

    date = df.report_date::Vector{Date}
    prev_day_admin = coalesce.(df.previous_day_total_doses_administered,0)::Vector{Int}
    total_individuals_1min = coalesce.(df.total_individuals_at_least_one,0)::Vector{Int}
    total_doses_admin = coalesce.(df.total_doses_administered,0)::Vector{Int}
    total_2doses = coalesce.(df.total_individuals_fully_vaccinated,0)::Vector{Int}
    total_3doses = coalesce.(df.total_individuals_3doses,0)::Vector{Int}

    # insert a data row for 2020-12-29 by using previous_day_doses_administered
    insert!(date, 2, date[2]-Day(1))
    insert!(total_doses_admin, 2, total_doses_admin[2] - prev_day_admin[2])
    insert!(prev_day_admin, 2, 0)
    insert!(total_individuals_1min, 2, 0)
    insert!(total_2doses, 2, 0)
    insert!(total_3doses, 2, 0)

    # insert missing rows between 24th & 29th
    splice!(date, 2:1, date[2].-Day.(4:-1:1))
    splice!(total_doses_admin, 2:1, fill(total_doses_admin[1],4))
    splice!(prev_day_admin, 2:1, fill(0,4))
    splice!(total_individuals_1min, 2:1, fill(0,4))
    splice!(total_2doses, 2:1, fill(0,4))
    splice!(total_3doses, 2:1, fill(0,4))

    # manipulations to get daily data
    daily_dose = diff([0;total_doses_admin])
    daily_date = date .- Day(1)
    daily_2doses = diff([0;total_2doses])
    daily_3doses = diff([0;total_3doses])

    # plot
    layout_options = (xaxis_title="Date", yaxis_rangemode="tozero", legend_xanchor="left", legend_x=0.01, paper_bgcolor="rgba(255,255,255,0)", plot_bgcolor="rgba(255,255,255,0)", margin_l=50, margin_r=50, margin_t=50, margin_b=50)

    ont_pop = 14_733_119
    dtick = get_dtick(maximum(total_individuals_1min))

    t1 = bar(x=date,y=total_3doses,name="Three doses")
    t2 = bar(x=date,y=total_2doses.-total_3doses,name="Two doses")
    t3 = bar(x=date,y=total_doses_admin.-(total_3doses.*3).-(total_2doses.-total_3doses).*2,name="One dose")
    t4 = scatter(x=date,y=total_individuals_1min./ont_pop,yaxis="y2",name="",opacity=0,showlegend=false)
    p1 = Plot([t1,t2,t3,t4], Layout(yaxis_title="People Vaccinated",barmode="stack";layout_options...,
        yaxis_dtick=dtick,yaxis2_dtick=dtick/ont_pop,yaxis2_rangemode="tozero",yaxis2_tickformat=",.1%",yaxis2_side="right",yaxis2_overlaying="y",yaxis2_scaleanchor="y",yaxis2_scaleratio=ont_pop,yaxis2_showgrid=false))


    t1 = bar(x=daily_date,y=daily_3doses,name="Third Doses")
    t2 = bar(x=daily_date,y=daily_2doses,name="Second Doses")
    t3 = bar(x=daily_date,y=daily_dose.-daily_3doses.-daily_2doses,name="First Doses")
    t4 = scatter(x=daily_date[7:end],y=moving_average(daily_dose,7),name="7-Day Average")
    p2 = Plot([t1,t2,t3,t4], Layout(yaxis_title="Doses",barmode="stack";layout_options...))

    return p1, p2
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
    ventilator = coalesce.(df.Num_of_patients_in_ICU_on_a_ventilator_testing_positive,0)::Vector{Int} .+
        coalesce.(df.Num_of_patients_in_ICU_on_a_ventilator_testing_negative,0)
    icu = coalesce.(df.Number_of_patients_in_ICU_testing_positive_for_COVID_19,0)::Vector{Int} .+ 
        coalesce.(df.Number_of_patients_in_ICU_testing_negative_for_COVID_19,0)::Vector{Int}
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
    layout_options = (xaxis_range=[date[18],date[end]+Day(1)], xaxis_title="Date", yaxis_rangemode="tozero", legend_xanchor="left", legend_x=0.01, paper_bgcolor="rgba(255,255,255,0)", plot_bgcolor="rgba(255,255,255,0)", margin_l=50, margin_r=50, margin_t=50, margin_b=50)

    t1 = bar(x=date,y=active,name="Active")
    t2 = bar(x=date,y=recovered,name="Recovered")
    t3 = bar(x=date,y=deceased,name="Deceased")
    p1 = Plot([t1,t2,t3], Layout(yaxis_title="Cases",barmode="stack";layout_options...))

    t1 = bar(x=date,y=daily_positive,name="Daily")
    t2 = scatter(x=date[7:end],y=moving_average(daily_positive,7),name="7-Day Average")
    p2 = Plot([t1,t2], Layout(yaxis_title="New Cases",barmode="stack";layout_options...))

    t1 = bar(x=date,y=max.(hospitalized.-icu,0),name="Hospitalized, not in ICU")
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

    idx = icu .!= 0
    frac_icu = icu[idx]./hospitalized[idx].*100
    frac_vent = ventilator[idx]./icu[idx].*100
    X = [fill!(similar(frac_icu),1) 1:length(frac_icu)]
    A1 = X*linreg(X,frac_icu)
    A2 = X*linreg(X,frac_vent)

    t1 = scatter(x=date[idx],y=frac_icu,mode="markers",name="Fraction of hospitalized patients in ICU")
    t2 = scatter(x=date[idx],y=frac_vent,mode="markers",name="Fraction of patients in ICU on a ventilator")
    t3 = scatter(x=date[idx],y=A1,name="")
    t4 = scatter(x=date[idx],y=A2,name="")
    p7 = Plot([t1,t2,t3,t4], Layout(yaxis_title="Percentage (%)",yaxis_range=[0,100];layout_options...))

    return p1, p2, p3, p4, p5, p6, p7
end

# backward-looking moving average
moving_average(vs,n) = [sum(@view vs[i-n+1:i])/n for i in n:length(vs)]

# linear regression
linreg(x::Matrix, y::Array) = x\y

function get_dtick(ymax)
    @assert ymax > 1 # method only works for values larger than 1
    units = [1,2,5,10]
    dtick = round(Int,ymax)
    tdiff = ymax/1
    for nticks in 5:9
        Δ = ymax/nticks
        pow = floor(Int, log10(Δ))
        m = round(Int, Δ/10^pow)
        u = units[argmin(abs.(m.-units))]
        d = u*10^pow
        if abs(d-Δ) < tdiff
            tdiff = abs(d-Δ)
            dtick = d
        end
    end
    return dtick
end

end # module
