import strutils, sequtils

const input = "467528193"

# Each index represents a cup value and holds the value of the next cup
# From a tip on reddit. My previous implementation used a DoublyLinkedRing
# (from the lists module) combined with a seq[DoublyLinkedNoke] as an index
# and took about 7 s to solve. This versions runs in about 0.8 s.
type SeqRing = seq[int]

type GameState = object
  cups: SeqRing
  cur: int
  minCup: int
  maxCup: int

iterator listItems(r: SeqRing, start: int): int =
  yield start
  var cur = r[start]
  while cur != start:
    yield cur
    cur = r[cur]

func initGame(text: string): GameState =
  let first = parseInt($text[0])
  result.cur = first
  result.minCup = int.high
  result.maxCup = int.low

  result.cups = newSeq[int](text.len + 1)
  for (i, chr) in text.pairs:
    let cur = parseInt($chr)
    let next = if i == text.high: first else: parseInt($text[i+1])
    result.cups[cur] = next
    if cur > result.maxCup: result.maxCup = cur
    if cur < result.minCup: result.minCup = cur

proc playRound(game: var GameState) =
  var
    nextCup = game.cups[game.cur]
    pickedCups: array[3, int]
  for i in countDown(2, 0):
    pickedCups[i] = nextCup
    nextCup = game.cups[nextCup]
  game.cups[game.cur] = nextCup

  var destVal = game.cur
  while destVal == game.cur or destVal in pickedCups:
    destVal.dec
    if destVal < game.minCup: destVal = game.maxCup

  for pCup in pickedCups:
    game.cups[pCup] = game.cups[destVal]
    game.cups[destVal] = pCup

  game.cur = game.cups[game.cur]

func finalScore(g: GameState): string =
  toSeq(g.cups.listItems(1)).join("")[1..^1]

var game = input.initGame
for i in 0..<100: game.playRound
let pt1 = game.finalScore
echo pt1
doAssert pt1 == "43769582"

# Part 2

func initGamePt2(init: string): GameState =
  result = init.initGame
  result.cups.setLen(1_000_001)

  let tail = parseInt($init[^1])
  result.cups[tail] = result.maxCup + 1

  for i in (result.maxCup + 1 ..< 1_000_000):
    result.cups[i] = i + 1
  result.cups[1_000_000] = result.cur
  result.maxCup = 1_000_000

proc part2Score(g: GameState): int =
  result = 1
  var cur = 1
  for i in 0..1:
    cur = game.cups[cur]
    result = result * cur

game = input.initGamePt2
for i in 0..<10_000_000:
  game.playRound
let pt2 = game.part2Score
echo pt2
doAssert pt2 == 264692662390
