module OntarioCOVID19

using HTTP, CSV, DataFrames, Dates, PyPlot

export get_summary_data, plot_total_cases, plot_testing

function get_summary_data()
    url = "https://data.ontario.ca/dataset/f4f86e54-872d-43f8-8a86-3892fd3cb5e6/resource/ed270bb8-340b-41f9-a7c6-e8ef587e6d11/download/covidtesting.csv"
    return CSV.File(HTTP.get(url).body) |> DataFrame
end

function plot_total_cases(df::DataFrame)
    # download data
    df = dropmissing(df, Symbol("Total Cases"), disallowmissing=true)

    # cases
    date = df[:,Symbol("Reported Date")]
    total = df[:,Symbol("Total Cases")]
    daily = diff([0;total])
    active = coalesce.(df[:,Symbol("Confirmed Positive")], 0)
    recovered = coalesce.(df[:,Symbol("Resolved")], 0)
    deceased = coalesce.(df[:,Symbol("Deaths")], 0)
    deceased = coalesce.(df[:,Symbol("Deaths")], 0)
    ventilator = coalesce.(df[:,Symbol("Number of patients in ICU on a ventilator with COVID-19")], 0)
    icu = coalesce.(df[:,Symbol("Number of patients in ICU with COVID-19")], 0)
    hospitalized = coalesce.(df[:,Symbol("Number of patients hospitalized with COVID-19")], 0)

    # plot
    fig, (ax1, ax2, ax3) = subplots(3,1,sharex=true,figsize=(9,12))

    ax1.bar(date,active)
    ax1.bar(date,recovered,bottom=active)
    ax1.bar(date,deceased,bottom=active.+recovered)
    ax1.grid(true)
    ax1.set(xlim=[date[20],date[end]+Day(1)],ylabel="Cases")
    ax1.legend(["Active","Recovered","Deceased"])

    ax2.bar(date,daily)
    ax2.grid(true)
    ax2.set(ylabel="Daily New Cases")

    ax3.bar(date,hospitalized.-icu)
    ax3.bar(date,icu.-ventilator,bottom=hospitalized.-icu)
    ax3.bar(date,ventilator,bottom=hospitalized.-ventilator)
    ax3.grid(true)
    ax3.set(xlabel="Date", ylabel="Hospitalized Cases")
    ax3.legend(["Hospitalized, not in ICU","ICU without ventilator","On a ventilator"])

    tight_layout(true)
    return fig
end

function plot_testing(df::DataFrame)
    # download data
    df = dropmissing(df, Symbol("Total Cases"), disallowmissing=true)

    # cases
    date = df[:,Symbol("Reported Date")]
    tests = coalesce.(df[:,Symbol("Total patients approved for testing as of Reporting Date")],0)
    total_positive = df[:,Symbol("Total Cases")]
    daily_positive = diff([0;total_positive])
    #negative = coalesce.(df[:,Symbol("Confirmed Negative")], 0) # missing data...
    investigating = coalesce.(df[:,Symbol("Under Investigation")], 0)
    presumed_pos = coalesce.(df[:,Symbol("Presumptive Positive")], 0)
    presumed_neg = coalesce.(df[:,Symbol("Presumptive Negative")], 0)

    investigating .+= presumed_pos .+ presumed_neg
    negative = max.(tests .- total_positive .- investigating, 0)

    daily_total = diff([0; total_positive .+ negative .+ investigating])

    # plot
    fig, (ax1, ax2, ax3) = subplots(3,1,sharex=true,figsize=(9,12))

    ax1.bar(date,negative)
    ax1.bar(date,investigating,bottom=negative)
    ax1.bar(date,total_positive,bottom=investigating.+negative)
    ax1.grid(true)
    ax1.set(xlim=[date[20],date[end]+Day(1)],ylabel="Tests")
    ax1.legend(["Negative","Pending","Positive"])

    ax2.plot(date,daily_positive./daily_total.*100)
    ax2.plot(date[7:end],moving_average(daily_positive./daily_total,7).*100)
    ax2.grid(true)
    ax2.set(ylim=(0,18),ylabel="Positivity Rate (%)")
    ax2.legend(["Daily","7-Day Average"])

    ax3.bar(date,daily_total,label="Daily")
    ax3.plot(date[7:end],moving_average(daily_total,7),color="C1",label="7-Day Average")
    ax3.grid(true)
    ax3.set(ylabel="Daily Tests")
    handles,labels = ax3.get_legend_handles_labels()
    ax3.legend(reverse(handles),reverse(labels))

    tight_layout(true)
    return fig
end

# backward-looking moving average
moving_average(vs,n) = [sum(@view vs[i-n+1:i])/n for i in n:length(vs)]

end # module
