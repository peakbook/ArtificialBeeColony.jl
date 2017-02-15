__precompile__()

module ArtificialBeeColony

export ABC
export search!

abstract TargetSystem

type TimeVariant <: TargetSystem
end

type TimeInvariant <: TargetSystem
end

type Bee
    data :: Vector
    fitness :: AbstractFloat
    count :: Integer
end

function Bee(data::Vector)
    Bee(data, zero(Float64), 0)
end

typealias Bees Vector{Bee}

function Base.copy!(t::Bee, s::Bee)
    copy!(t.data, s.data)
    t.fitness = s.fitness
    t.count = s.count
    return t
end

function Base.copy(s::Bee)
    return Bee(copy(s.data), s.fitness, s.count)
end

type ABC
    bees :: Bees
    best :: Bee
    init :: Function
    function ABC(N::Integer, init::Function)
        dim = length(init())
        bees = Bee[Bee(init()) for i=1:N]
        new(bees, Bee(zeros(dim)), init)
    end
end

@inline function update_fitness!(bee::Bee, g::Function)
    bee.fitness = fitness(g(bee.data))
end

@inline function update_fitness!(bees::Bees, g::Function)
    for bee in bees
        update_fitness!(bee, g)
    end
end

function update_bee!(bee::Bee, beem::Bee, g::Function)
    dim = length(bee.data)
    phi = 2.0*(rand()-0.5)
    j = rand(1:dim)

    val = phi*(bee.data[j] - beem.data[j])

    bee.data[j] += val
    fitnew = fitness(g(bee.data))

    if fitnew > bee.fitness
        bee.fitness = fitnew
        bee.count = 0
    else
        bee.data[j] -= val
        bee.count += 1
    end
end

function update_employed!(bees::Bees, g::Function, mode::TimeInvariant)
    N = length(bees)
    for bee in bees
        update_bee!(bee, bees[rand(1:N)], g)
    end
end

function update_employed!(bees::Bees, g::Function, mode::TimeVariant)
    N = length(bees)
    for bee in bees
        update_fitness!(bee, g)
        update_bee!(bee, bees[rand(1:N)], g)
    end
end

function roulette_select(bees::Bees)
    sf = sum(map(x->x.fitness, bees))
    r = rand()
    rs = zero(r)

    for bee in bees
        rs += bee.fitness/sf
        if r<=rs
            return bee
        end
    end
    return bees[end]
end

function update_outlook!(bees::Bees, g::Function, No::Integer, mode::TimeInvariant)
    N = length(bees)
    for i=1:No
        bee = roulette_select(bees)
        update_bee!(bee, bees[rand(1:N)], g)
    end
end

function update_outlook!(bees::Bees, g::Function, No::Integer, mode::TimeVariant)
    N = length(bees)
    for i=1:No
        bee = roulette_select(bees)
        update_fitness!(bee, g)
        update_bee!(bee, bees[rand(1:N)], g)
    end
end

function update_scout!(bees::Bees, g::Function, init::Function, limit::Integer, mode::TimeInvariant)
    bees_scout = filter(x->x.count >= limit, bees)
    for bee in bees_scout
        bee.data = init()
        bee.count = 0
    end
    update_fitness!(bees_scout, g)
end

function update_scout!(bees::Bees, g::Function, init::Function, limit::Integer, mode::TimeVariant)
    bees_scout = filter(x->x.count >= limit, bees)
    for bee in bees_scout
        bee.data = init()
        bee.count = 0
    end
end

function find_best(bees::Bees)
    best = bees[1]
    for bee in bees
        if bee.fitness > best.fitness
            best = bee
        end
    end
    return best
end

function update_best!(bees::Bees, bee_best::Bee, mode::TimeInvariant)
    bee_cand = find_best(bees)
    if bee_best.fitness < bee_cand.fitness
        copy!(bee_best, bee_cand)
    end
end

function update_best!(bees::Bees, bee_best::Bee, mode::TimeVariant)
    copy!(bee_best, find_best(bees))
end

function search!(abc::ABC, g::Function; epoch::Integer=1000, time_invariant::Bool=false)
    mode = time_invariant ? TimeInvariant() : TimeVariant()

    Ne = length(abc.bees)
    No = length(abc.bees)
    dim = length(abc.bees[1].data)
    limit = round(Integer, 0.1*dim*(Ne+No))

    if time_invariant
        update_fitness!(abc.bees, g)
    end
    for i=1:epoch
        update_employed!(abc.bees, g, mode)
        update_outlook!(abc.bees, g, No, mode)
        update_best!(abc.bees, abc.best, mode)
        update_scout!(abc.bees, g, abc.init, limit, mode)
    end
    return abc.best.data
end

function fitness{T<:AbstractFloat}(val::T)
    if val >= zero(T)
        return one(T)/(one(T)+val)
    else
        return one(T)+abs(val)
    end
end

end
