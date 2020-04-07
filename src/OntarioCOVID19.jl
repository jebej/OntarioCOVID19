module OntarioCOVID19

using CSVFiles, DataFrames, Dates, PyPlot

export get_summary_data, plot_total_cases

function get_summary_data()
    url = "https://data.ontario.ca/dataset/f4f86e54-872d-43f8-8a86-3892fd3cb5e6/resource/ed270bb8-340b-41f9-a7c6-e8ef587e6d11/download/covidtesting.csv"
    return DataFrame(load(url,header_exists=true))
end

function plot_total_cases()
    # download data
    df = dropmissing(get_summary_data(), Symbol("Total Cases"), disallowmissing=true)

    # cases
    date = df[:,Symbol("Reported Date")]
    total = df[:,Symbol("Total Cases")]
    daily = [0;diff(total)]
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
    ax1.set(xlim=[date[17],date[end]+Day(1)],ylabel="Cases")
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
    return nothing
end

end # module
