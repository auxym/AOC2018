import strutils, sequtils, sets, tables

type
    Direction = enum U, D, L, R
    Segment = tuple[dir: Direction, len: int]
    Path = seq[Segment]
    Point2D = tuple[x, y: int]

const origin = (0, 0)

func parseSegment(s: string): Segment =
    result.dir = parseEnum[Direction]($s[0])
    result.len = parseInt(s[1..s.len-1])

func parsePath(s: string): seq[Segment] =
    s.strip.split(",").map(parseSegment)

func parseInput(s: string): seq[Path] =
    result = s.strip.splitLines.map(parsePath)

func `+`(a: Point2D, b: Point2D): Point2D =
    result = ((a.x + b.x), (a.y+b.y))

func manhattan(a, b: Point2D): int =
    result = abs(b.x - a.x) + abs(b.y - a.y)

func unitVector(d: Direction): Point2D =
    case d:
        of D: (0, -1)
        of U: (0, 1)
        of L: (-1, 0)
        of R: (1, 0)

iterator walkPath(p: Path): tuple[point: Point2D, steps: int] =
    var
        cur = origin
        steps = 0
    for seg in p:
        let u = seg.dir.unitVector
        for i in 1..seg.len:
            cur = cur + u
            inc steps
            yield (cur, steps)

func getVisitedCells(path: seq[Segment]): HashSet[Point2D] = 
    result = initHashSet[Point2D](sets.rightSize(65536))
    for c in path.walkPath:
        result.incl c.point

func getStepMap(path: Path): TableRef[Point2D, int] = 
    result = newTable[Point2D, int](tables.rightSize(65536))
    for (pt, nstp) in walkPath(path):
        if pt notin result:
            result[pt] = nstp
        else:
            if result[pt] > nstp:
                result[pt] = nstp

let input = readFile("./input/day03.txt").parseInput

#let input = """
#R8,U5,L5,D3
#U7,R6,D4,L4
#""".parseInput

#let input = """
#R75,D30,R83,U83,L12,D49,R71,U7,L72
#U62,R66,U55,R34,D71,R55,D58,R83
#""".parseInput

#let input = """
#R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
#U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
#""".parseInput

# Part 1
let
    v1 = input[0].getVisitedCells
    v2 = input[1].getVisitedCells
    inters = v1.intersection(v2)

var mindist = int.high
for p in inters:
    if p.manhattan(origin) < mindist:
        mindist = p.manhattan(origin)
echo mindist
doAssert mindist == 245

# Part 2
let
    stpMap1 = input[0].getStepMap
    stpMap2 = input[1].getStepMap

var minStepSum = int.high
for pt in inters:
    let totalSteps = stpMap1[pt] + stpMap2[pt]
    if totalSteps < minStepSum:
        minStepSum = totalSteps
echo minStepSum
doAssert minStepSum == 48262
