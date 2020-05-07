# code for kurtosis detections
using Statistics
using SeisIO
using Distributions
using Dierckx

#CHANGE INPUTS TO KURTOSIS

function getTriggersKurtosis(trace::Array{Float32,1},fs::Int=100,timeWinLength::Float64=60.,sparseWinLength::Float64=5.,
                threshold::Float64=3.)

    #convert window lengths from seconds to samples
    timeWin = trunc(Int,timeWinLength * fs)
    sparseWin = trunc(Int,sparseWinLength * fs)
    #overlap = trunc(Int,overlap * fs)

    #data.misc["kurtosis"] = fast_kurtosis_series(data.x, TimeWin, SparseWin)

    kurt = zeros(length(trace))
    triggers = zeros(length(trace))
    n = length(trace)
    kurt_grid = 1:n

    if n < timeWin error("Kurtosis time window is larger than data length. Decrease time window length.") end
    if sparseWin > timeWin error("Sparse window is larger than Kurtosis time window. Decrease sparse window length.") end

    #1. compute kurtosis with sparse grid
    kurt_sparse_grid = collect(timeWin:sparseWin:n)
    if kurt_sparse_grid[end] != n
        # fill up the edge of time series
        push!(kurt_sparse_grid, n)
    end

    kurt_sparse = []

    cm2 = 0.0  # empirical 2nd centered moment (variance)
    cm4 = 0.0  # empirical 4th centered moment

    t0 = @elapsed @simd for k = kurt_sparse_grid
        window = @views trace[k-timeWin+1:k]
        m0 = mean(window)

        cm2 = Statistics.varm(window, m0, corrected=false)
        cm4 = fourthmoment(window, m0, corrected=false) #sum(xi - m)^4 / N
        kurt[k] = (cm4 / (cm2 * cm2)) - 3.0

	if kurt[k] > threshold
	     triggers[k] = 1
	end	

    end

    return triggers

end


centralizedabs4fun(m) = x -> abs2.(abs2.(x - m))
centralize_sumabs4(A::AbstractArray, m) =
    mapreduce(centralizedabs4fun(m), +, A)
centralize_sumabs4(A::AbstractArray, m, ifirst::Int, ilast::Int) =
    Base.mapreduce_impl(centralizedabs4fun(m), +, A, ifirst, ilast)

function centralize_sumabs4!(R::AbstractArray{S}, A::AbstractArray, means::AbstractArray) where S
    # following the implementation of _mapreducedim! at base/reducedim.jl
    lsiz = Base.check_reducedims(R,A)
    isempty(R) || fill!(R, zero(S))
    isempty(A) && return R

    if Base.has_fast_linear_indexing(A) && lsiz > 16 && !has_offset_axes(R, means)
        nslices = div(length(A), lsiz)
        ibase = first(LinearIndices(A))-1
        for i = 1:nslices
            @inbounds R[i] = centralize_sumabs4(A, means[i], ibase+1, ibase+lsiz)
            ibase += lsiz
        end
        return R
    end
    indsAt, indsRt = Base.safe_tail(axes(A)), Base.safe_tail(axes(R)) # handle d=1 manually
    keep, Idefault = Broadcast.shapeindexer(indsRt)
    if Base.reducedim1(R, A)
        i1 = first(Base.axes1(R))
        @inbounds for IA in CartesianIndices(indsAt)
            IR = Broadcast.newindex(IA, keep, Idefault)
            r = R[i1,IR]
            m = means[i1,IR]
            @simd for i in axes(A, 1)
                r += abs2(abs2(A[i,IA] - m))
            end
            R[i1,IR] = r
        end
    else
        @inbounds for IA in CartesianIndices(indsAt)
            IR = Broadcast.newindex(IA, keep, Idefault)
            @simd for i in axes(A, 1)
                R[i,IR] += abs2(abs2(A[i,IA] - means[i,IR]))
            end
        end
    end
    return R
end

function fourthmoment!(R::AbstractArray{S}, A::AbstractArray, m::AbstractArray; corrected::Bool=true) where S
    if isempty(A)
        fill!(R, convert(S, NaN))
    else
        rn = div(length(A), length(R)) - Int(corrected)
        centralize_sumabs4!(R, A, m)
        R .= R .* (1 // rn)
    end
    return R
end

"""
    fourthmoment(v, m; dims, corrected::Bool=true)
Compute the fourthmoment of a collection `v` with known mean(s) `m`,
optionally over the given dimensions. `m` may contain means for each dimension of
`v`. If `corrected` is `true`, then the sum is scaled with `n-1`,
whereas the sum is scaled with `n` if `corrected` is `false` where `n = length(v)`.
!!! note
    If array contains `NaN` or [`missing`](@ref) values, the result is also
    `NaN` or `missing` (`missing` takes precedence if array contains both).
    Use the [`skipmissing`](@ref) function to omit `missing` entries and compute the
    variance of non-missing values.
"""
fourthmoment(A::AbstractArray, m::AbstractArray; corrected::Bool=true, dims=:) = _fourthmoment(A, m, corrected, dims)

_fourthmoment(A::AbstractArray{T}, m, corrected::Bool, region) where {T} =
    fourthmoment!(Base.reducedim_init(t -> abs2(t)/2, +, A, region), A, m; corrected=corrected)

fourthmoment(A::AbstractArray, m; corrected::Bool=true) = _fourthmoment(A, m, corrected, :)

function _fourthmoment(A::AbstractArray{T}, m, corrected::Bool, ::Colon) where T
    n = length(A)
    n == 0 && return oftype((abs2(zero(T)) + abs2(zero(T)))/2, NaN)
    return centralize_sumabs4(A, m) / (n - Int(corrected))
end


