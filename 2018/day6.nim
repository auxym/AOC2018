import strUtils
import strscans
import seqUtils
import tables

type 
    Coord = tuple[x, y: int]

func manhattan(a, b: Coord): int =
    result = abs(b.x - a.x) + abs(b.y - a.y)

proc parseInput(line: string): Coord = 
    var x, y: int
    if not scanf(line.strip(), "$i, $i", x, y):
        raise newException(ValueError, line)
    result = (x, y)

func findClosest(a: Coord, arr: openArray[Coord]): seq[Coord] =
    var
        distances = initTable[int, seq[Coord]](tables.rightSize(arr.len))
        mindist = manhattan(a, arr[0])
    
    for b in arr:
        let dist = manhattan(a, b)
        if dist < mindist: mindist = dist
        if not distances.contains(dist): distances.add(dist, @[])
        distances[dist].add b
    
    result = distances[mindist]

func findBounds(coords: seq[Coord]): (Coord, Coord) =
    var
        max_x = coords[0].x
        min_x = coords[0].x
        max_y = coords[0].y
        min_y = coords[0].y
    for c in coords:
        if c.x > max_x: max_x = c.x
        if c.x < min_x: min_x = c.x
        if c.y > max_y: max_y = c.y
        if c.y < min_y: min_y = c.y

    result = ((min_x, min_y), (max_x, max_y))

var input: seq[Coord]
for line in readFile("./day6_input.txt").strip().splitLines():
    input.add(parseInput(line))

# Boundaries of a rectangle that includes all points in input
let (upperLeft, lowerRight) = findBounds(input)

# Part 1
var finiteAreas = initTable[Coord, int](tables.rightSize(input.len))
for c in input:
    finiteAreas[c] = 0

for j in upperLeft.y .. lowerRight.y:
    for i in upperLeft.x .. lowerRight.x:
        let owners = findClosest((i, j), input)

        if owners.len == 1 and (
           i == upperLeft.x or
           i == lowerRight.x or
           j == upperLeft.y or
           j == lowerRight.y):
            for o in owners:
                finiteAreas.del o

        if owners.len == 1 and finiteAreas.contains(owners[0]):
            inc finiteAreas[owners[0]]

echo toSeq(finiteAreas.values).max

# Part 2
var part2Area = 0
for j in upperLeft.y .. lowerRight.y:
    for i in upperLeft.x .. lowerRight.x:
        let c: Coord = (i, j)
        var totalDist = 0
        for entry in input:
            totalDist += manhattan(c, entry)
            if totalDist >= 10_000:
                break
        if totalDist < 10_000:
            inc part2Area

echo part2Area