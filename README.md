# ArtificialBeeColony
Artificial Bee Colony (ABC) algorithm.

## Usage
``` julia
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

abc = ABC(dim, N, init)
best = search!(abc, target; epoch=epoch, time_invaliant=flag)

println("x = ", best[1])
println("target(x) = ", target(best))
```

![ABC_example](http://peakbook.github.io/images/ABC_example.svg)

## References
- [D. Karaboga and B. Basturk, ``A powerful and efficient algorithm for numerical function optimization: artificial bee colony (ABC) algorithm,`` Journal of global optimization, 39(3), pp.459-471, 2007](http://link.springer.com/article/10.1007/s10898-007-9149-x).
- <http://mf.erciyes.edu.tr/abc/>
- <https://en.wikipedia.org/wiki/Artificial_bee_colony_algorithm>
