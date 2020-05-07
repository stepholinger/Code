#reads list in the following format: "[1000, 1000, 1000,...,1000]" into an array


function readList(infile=String)

	f = open(infile)

	list = read(f,String)

	list = split(list[2:end-1],", ")

	if occursin("loat64[",list[1])==false

		elements = zeros(size(list)[1])

		for n in 1:size(list)[1] 
      			elements[n] = parse(Float64,list[n])
		end

		return elements
	end

end
