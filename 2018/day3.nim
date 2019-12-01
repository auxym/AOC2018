import strutils
import regex
import seqUtils

const FABRIC_SZ = 1000

let input = readFile("./day3_input.txt").strip.splitLines
#let input = """
#1 @ 1,3: 4x4
#2 @ 3,1: 4x4
#3 @ 5,5: 2x2
#""".strip().splitLines()

let line_pat = re"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)"

type Claim = tuple[id: int, rows: Slice[int], cols: Slice[int]]
type Fabric = array[FABRIC_SZ, array[FABRIC_SZ, int]]
type Coords = tuple[x: int, y: int]

func parseline(line: string): Claim = 
    var m: RegexMatch
    assert match(line, line_pat, m)

    let id = line[m.group(0)[0]].parseInt

    let rowStart = line[m.group(1)[0]].parseInt
    let colStart = line[m.group(2)[0]].parseInt

    let rowEnd = rowStart + line[m.group(3)[0]].parseInt
    let colEnd = colStart + line[m.group(4)[0]].parseInt

    let rows: Slice[int] = rowStart..<rowEnd
    let cols: Slice[int] = colStart..<colEnd

    return (id, rows, cols)

iterator iterClaim(c: Claim): Coords = 
    for rw in c.rows:
        for cl in c.cols:
            yield (rw, cl)

proc printArray(x: Fabric) = 
    for row in x:
        var rowStr = ""
        for it in row:
            if it == 0:
                rowStr.add '.'
            else:
                rowStr.add $it
        echo rowStr

var fabric: Fabric

let claimsList = input.map(parseline)

# part 1
var numSqInchesInMultipleClaims = 0
for claim in claimsList:
    for sq in claim.iterClaim:
        inc fabric[sq.x][sq.y]
        if fabric[sq.x][sq.y] == 2 : inc numSqInchesInMultipleClaims

echo numSqInchesInMultipleClaims

# part 2
for claim in claimsList:
    var hasOverlap = false
    for sq in claim.iterClaim:
        if fabric[sq.x][sq.y] > 1:
            hasOverlap = true
            break
    if not hasOverlap:
        echo "#", claim.id