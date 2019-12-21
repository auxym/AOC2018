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

# input = """
# .#..#
# .....
# #####
# ....#
# ...##
# """ |> parseinput

input = open(f->read(f, String), "./input/day10.txt") |> strip |> parseinput

input.asteroids |> findbestbase |> println

#countvisible(input.asteroids, Point2D(3, 4)) |> println

