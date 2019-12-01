import strutils, sequtils

let input = readFile("./input/day01.txt").strip.splitLines.map(parseInt)

func totalFuel(m: int): int =
    result = m div 3 - 2
    if result < 0:
        result = 0
    if result > 0:
        result += totalFuel(result)

# part 1
echo input.mapIt(it div 3 - 2).foldl(a + b)

# part 2
echo input.map(totalFuel).foldl(a+b)