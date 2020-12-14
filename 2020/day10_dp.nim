import utils, algorithm, sequtils

let adapterList = @[0] & readFile("./input/day10_input.txt").getInts.sorted()

func countValidArrangements(adapters: seq[int]): int =
  proc helper(adapters: seq[int], start: Natural, dp: var seq[int]): int =
    if start == adapters.high:
      return 1
    elif dp[start] != -1:
      return dp[start]

    result = 0
    for j in (start + 1)..(start + 3):
      if j > adapters.high:
        break
      elif adapters[j] <= adapters[start] + 3:
        result = result + helper(adapters, j, dp)
    dp[start] = result

  var dp = newSeqWith(adapters.len, -1)
  result = helper(adapters, 0, dp)

let pt2ans = countValidArrangements(adapterList)
doAssert pt2ans == 113387824750592
echo pt2ans