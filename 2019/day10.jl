using StaticArrays
using LinearAlgebra

const Point2D = SVector{2, Float64}

struct LineSegment
    p1::Point2D
    p2::Point2D
end

struct InputMap
    asteroids::Array{Point2D}
    mapsize::NamedTuple{(:rows, :cols), Tuple{Int, Int}}
end

function splitlines(s::AbstractString)
    split(s, r"\r?\n")
end

function parseinput(s::AbstractString)::InputMap
    lines = (s |> strip |> splitlines)
    asteroids::Array{Point2D} = []
    for (irow, ln) in enumerate(lines), (icol, cr) in enumerate(strip(ln))
        if cr == '#'
            push!(asteroids, Point2D(icol - 1, irow - 1))
        end
    end
    nrows = length(lines)
    ncols = length(strip(lines[1]))
    return InputMap(asteroids, (rows=nrows, cols=ncols))
end

function ispointonline(p::Point2D, lnseg::LineSegment)::Bool
    tol = 1e-8
    ab = lnseg.p2 - lnseg.p1
    ac = p - lnseg.p1

    k_ac = dot(ab, ac)
    if abs(k_ac / norm(ab) / norm(ac) - 1) > tol
        return false
    end

    k_ab = dot(ab, ab)
    k_ac > 0 && k_ac < k_ab
end

function cansee(from::Point2D, to::Point2D, allastr::Array{Point2D})::Bool
    line_of_sight = LineSegment(from, to)

    for ast in allastr
        if ast == from || ast == to
            continue
        elseif ispointonline(ast, line_of_sight)
            #println("$from -> $to blocked by $ast")
            return false
        end
    end
    return true
end

function findbestbase(asteroids::Array{Point2D})::Tuple{Point2D, Integer}
    bb = (Point2D(0,0), 0)
    for base in asteroids
        numvisible = count(a -> a != base && cansee(base, a, asteroids),
                           asteroids)
        if numvisible > bb[2]
            bb = (base, numvisible)
        end
    end
    return bb
end

input = open(f->read(f, String), "./input/day10.txt") |> strip |> parseinput

base, numvisible = findbestbase(input.asteroids)
println("Base $base can see $numvisible asteroids")

function cart2polar(o::Point2D, a::Point2D, phase=0)::Point2D
    oa = a - o
    θ = atan(oa[2], oa[1]) - phase |> mod2pi
    return Point2D(θ, norm(oa))
end

function polar2cart(o::Point2D, a::Point2D, phase=0)::Point2D
    θ, r = a 
    x = r * cos(θ + phase)
    y = r * sin(θ + phase)
    return Point2D(x, y) + o
end

function groupbyfirst(items::Array{T})::Array{Array{T}} where T
    result::Array{Array{T}} = []
    group::Array{T} = []
    disc = items[1][1]
    for it in items
        if abs(it[1] - disc) < 1E-8
            push!(group, it)
        else
            push!(result, group)
            group = [it]
            disc = it[1]
        end
    end
    push!(result, group)
    result
end

function blastasteroids(asteroids::Array{Point2D}, num::Integer)
    phase = -π / 2
    prasteroids = (x -> cart2polar(base, x, phase)).(asteroids)
    prasteroids = filter(a -> a[2] > 0.01, prasteroids)
    sort!(prasteroids)

    anglegroups = groupbyfirst(prasteroids)

    killcount = 0
    while true && length(anglegroups) > 0
        next = []
        for g in anglegroups
            victim = g[1]
            #println("blast $victim ($(polar2cart(base, victim, phase)))")
            killcount += 1
            if killcount == num
                return polar2cart(base, victim, phase)
            end
            if length(g) > 1
                push!(next, g[2:end])
            end
        end
        anglegroups = next
    end
end

blastasteroids(input.asteroids, 200) |> println