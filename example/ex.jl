using ArtificialBeeColony

# initializer for bees' position
function init()
    rand(1)*20-10   # [-10, 10] 
end

# target function
function target(x::Vector{Float64})
    x[1]^2+10*sin(2*x[1])
end

N = 50       # the number of bees
epoch = 100  # the number of iteration
flag = true  # time invariant flag

abc = ABC(N, init)
best = search!(abc, target; epoch=epoch, time_invariant=flag)

println("x = ", best[1])
println("target(x) = ", target(best))
