import utils, intcode

let program = readFile("./input/day05.txt").getInts

let part1 = program.runAndGetOutput(@[1])
doAssert part1[^1] == 6745903
echo part1

let part2 = program.runAndGetOutput(@[5])
doAssert part2[0] == 9168267
echo part2