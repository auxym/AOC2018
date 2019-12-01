import strutils, sequtils

type
    Tile = enum Trees, LumberYard, Open
    Grid = seq[seq[Tile]]

func toTile(c: char): Tile =
    case c:
        of '#':
            return LumberYard
        of '|':
            return Trees
        of '.':
            return Open
        else:
            raise newException(ValueError, "Invalid char " & c)

proc readInput(fname: string): Grid =
    let input = readFile(fname).strip()
    for line in input.splitlines():
        result.add toSeq(line.items).map(toTile)

func getNeighbors(g: Grid, x, y: int): seq[Tile] =
    if x > g[0].low:
        result.add g[y][x-1]
        if y > g.low: result.add g[y-1][x-1]
        if y < g.high: result.add g[y+1][x-1]

    if y > g.low: result.add g[y-1][x]
    if y < g.high: result.add g[y+1][x]

    if x < g[0].high:
        result.add g[y][x+1]
        if y > g.low: result.add g[y-1][x+1]
        if y < g.high: result.add g[y+1][x+1]


func tick(g: Grid): Grid =
    result = g
    for j, row in g:
        for i, t in row:
            let nbors = g.getNeighbors(i, j)
            var next = t
            case t:
                of Open:
                    if nbors.filterIt(it == Trees).len >= 3:
                        next = Trees
                of Trees:
                    if nbors.filterIt(it == LumberYard).len >= 3:
                        next = LumberYard
                of LumberYard:
                    if not (nbors.anyIt(it == LumberYard) and
                            nbors.anyIt(it == Trees)):
                        next = Open
            result[j][i] = next

func resValue(g: Grid): (int, int) =
    var
        nlum = 0
        ntrees = 0

    for row in g:
        for t in row:
            case t:
                of Trees:
                    inc ntrees
                of LumberYard:
                    inc nlum
                of Open:
                    discard
    
    return (nlum, ntrees)

func findPeriod(x: seq[int]): int =
    # From visual analysis, period is around 25
    result = 8
    while x[0..<result] != x[result..(result * 2 - 1)] and
          result <= (x.len div 2):
        inc result
    
    if  x[0..<result] != x[result..(result * 2 - 1)]:
        result = -1

var
    ntrees, nlum: int
    grid = readInput("./day18_input.txt")

# Part 1
for i in 0..<10:
    grid = tick(grid)
(ntrees, nlum) = grid.resValue()
echo ntrees*nlum

# Part 2
const ONE_BILLION = 1_000_000_000
grid = readInput("./day18_input.txt")

# For analysis in external program
# let outfile = open("./day18_stats.csv", fmWrite)

var score_samples = newSeqOfCap[int](1000)

# Automaton seems to stabilize around iteration 450
var i = 0
while i < 1000:
    inc i
    grid = tick(grid)
    (ntrees, nlum) = grid.resValue()
    # outfile.writeLine($ntrees & "," & $nlum)
    score_samples.add ntrees*nlum

let period = findPeriod(score_samples[800..900])

let remaining = (ONE_BILLION - i) mod period
for j in 0..<remaining:
    grid = tick(grid)
(ntrees, nlum) = grid.resValue()
echo ntrees*nlum