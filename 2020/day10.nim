import utils, algorithm, tables, sequtils

let adapterList = readFile("./input/day10_input.txt").getInts.sorted()

var joltDiffs = {3: 1}.toTable()
for i, adapter in adapterList.pairs:
  let
    prev = if i == 0: 0 else: adapterList[i-1]
    diff = adapter - prev
  if diff notin joltDiffs:
    joltDiffs[diff] = 0
  joltDiffs[diff] = joltDiffs[diff] + 1

let pt1ans = joltDiffs[1] * joltDiffs[3]
echo pt1ans
doAssert pt1ans == 1917

# Part 2
# Shout out to u/Nunki on reddit for this one: https://www.reddit.com/r/adventofcode/comments/kacdbl/2020_day_10c_part_2_no_clue_how_to_begin/gf9lzhd
# I had no clue where to even start for an efficient solution...

func countValidArrangements(adapters: seq[int]): int =
  let adapters = @[0] & adapters
  var pathCounts = adapters.mapIt((it, 0)).toTable()
  pathCounts[adapters[0]] = 1

  for i, cur in adapters.pairs:
    let pathsToCur = pathCounts[cur]
    var j = i + 1
    while j <= adapters.high and adapters[j] <= cur + 3:
      pathCounts[adapters[j]].inc pathsToCur
      inc j
  result = pathCounts[adapters[^1]]

let pt2ans = countValidArrangements(adapterList)
doAssert pt2ans == 113387824750592
echo pt2ans