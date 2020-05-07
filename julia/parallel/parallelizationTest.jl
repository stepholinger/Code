using Distributed
addprocs(20)

@everywhere begin
    using SeisIO
    using Dates
    include("testFunc.jl")
    startDate = Date("2012-05-01")
    endDate = Date("2012-05-20")
    dateRange = startDate:Day(1):endDate
end

test = pmap(testParallel,dateRange)
