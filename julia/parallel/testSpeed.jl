using Distributed
include("testFunc.jl")

startDate = Date("2012-05-01")
endDate = Date("2012-05-20")
dateRange = startDate:Day(1):endDate

s = Dates.now()

for d in dateRange
    testParallel(d)
end

e = Dates.now()

timeElapsed = e - s
print("Loop time: " * string(timeElapsed) * "\n")

s = Dates.now()

include("parallelizationTest.jl")

e = Dates.now()

timeElapsed = e - s
print("Pmap time: " * string(timeElapsed))
