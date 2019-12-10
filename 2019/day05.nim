import intcode, sequtils

let program = readIntCodeProgram("./input/day05.txt")

let part1 = program.runAndGetOutput(@[1])
doAssert part1[^1].toInt64 == 6745903
echo part1

let part2 = program.runAndGetOutput(@[5])
doAssert part2[0].toInt64 == 9168267
echo part2