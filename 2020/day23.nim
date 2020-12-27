import lists, strutils, strformat

const input = "467528193"

type GameState = object
  cups: DoublyLinkedRing[int]
  cur: DoublyLinkedNode[int]
  minCup: int
  maxCup: int
  index: seq[DoublyLinkedNode[int]]

func `$`(g: GameState): string =
  for e in g.cups:
    if e == g.cur.value:
      result.add fmt"({e}) "
    else:
      result.add $e & " "
  result = result[0..^2]

func initGame(text: string): GameState =
  result.minCup = int.high
  result.maxCup = int.low
  result.cups = initDoublyLinkedRing[int]()
  result.index = newSeq[DoublyLinkedNode[int]](text.len + 1)
  for ch in text:
    let x = ($ch).parseInt
    if x < result.minCup: result.minCup = x
    if x > result.maxCup: result.maxCup = x
    let node = newDoublyLinkedNode(x)
    result.index[x] = node
    result.cups.append node
  result.cur = result.cups.head

proc insertAfter[T](node: var DoublyLinkedNode[T], val: T): DoublyLinkedNode[T] =
  var newNode = newDoublyLinkedNode[T](val)
  newNode.prev = node
  newNode.next = node.next
  node.next.prev = newNode
  node.next = newNode
  return newNode

proc playRound(game: var GameState) =
  var pickedCups: seq[int]
  for i in 0..2:
    pickedCups.add game.cur.next.value
    game.cups.remove game.cur.next

  var destVal = game.cur.value
  while destVal == game.cur.value or destVal in pickedCups:
    destVal.dec
    if destVal < game.minCup: destVal = game.maxCup

  var dest = game.index[destVal]
  while pickedCups.len > 0:
    let cupval = pickedCups.pop
    game.index[cupval] = dest.insertAfter(cupval)

  game.cur = game.cur.next

func finalScore(g: GameState): string =
  let one = g.cups.find(1)
  var cur = one.next
  while cur != one:
    result = result & $cur.value
    cur = cur.next

var game = input.initGame
for i in 0..<100: game.playRound
let pt1 = game.finalScore
echo pt1
doAssert pt1 == "43769582"

# Part 2

func initGamePt2(init: string): GameState =
  result = init.initGame
  result.index.setLen(1_000_001)
  for i in (result.maxCup + 1 .. 1_000_000):
    let node = newDoublyLinkedNode(i)
    result.cups.append node
    result.index[i] = node
  result.maxCup = 1_000_000

func part2Score(g: GameState): int =
  let one = g.index[1]
  result = one.next.value * one.next.next.value

game = input.initGamePt2
for i in 0..<10_000_000:
  game.playRound
let pt2 = game.part2Score
echo pt2
doAssert pt2 == 264692662390
