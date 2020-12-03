import strutils, seqUtils

type ForestMap = seq[seq[bool]]

func parseInput(text: string): ForestMap =
    let lines = text.strip.splitLines
    result = newSeqOfCap[seq[bool]](lines.len)
    for ln in lines:
        result.add mapIt(ln, it == '#')

func `[]`(m: ForestMap, row, col: int): bool =
    let wcol = col mod m[0].len
    m[row][wcol]

func countTrees(fm: ForestMap, right, down: int): Natural =
    result = 0
    var pos = (0, 0)
    while pos[0] <= fm.high:
        if fm[pos[0], pos[1]]: inc result
        pos = (pos[0] + down, pos[1] + right)

let test_input = """
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
"""

let testMap = parseInput(test_input)
doAssert testMap[1, 3] == false
doAssert testMap[2, 6] == true
doAssert testMap[4, 12] == true
doAssert testMap.countTrees(3, 1) == 7

let fmap = readFile("./input/day03_input.txt").parseInput
echo fmap.countTrees(3, 1)

# part 2
let part2slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
var p2trees = 1
for slope in  part2slopes:
    p2trees = p2trees * fmap.countTrees(slope[0], slope[1])
echo p2trees