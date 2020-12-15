import tables, options

func playGame(start: seq[SomeInteger], turns: Natural): int32 =
  var
    gameState: Table[int32, int32]
    prev: int32 = start[^1].int32
    turn = start.len.int32 + 1

  for (i, val) in start[0..^2].pairs:
    gameState[val.int32] = i.int32 + 1

  while turn <= turns:
    let found_idx = gameState.getOrDefault(prev, 0'i32)
    gameState[prev] = turn - 1
    prev = if found_idx == 0: found_idx else: (turn - 1 - found_idx)
    inc turn
  prev

block testCases:
  doAssert @[0, 3, 6].playGame(10) == 0
  doAssert @[1, 3, 2].playGame(2020) == 1
  doAssert @[2, 1, 3].playGame(2020) == 10
  doAssert @[1, 2, 3].playGame(2020) == 27
  doAssert @[3, 2, 1].playGame(2020) == 438
  doAssert @[3, 2, 1].playGame(2020) == 438
  doAssert @[3, 1, 2].playGame(2020) == 1836

const input_start = @[2,0,6,12,1,3]

let pt1 = input_start.playGame(2020)
echo pt1
doAssert pt1 == 1428

const pt2_turns = 30_000_000

let pt2 = input_start.playGame(pt2_turns)
echo pt2
doAssert pt2 == 3718541
