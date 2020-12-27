import lists, sequtils, strutils, strformat

const
  input = "467528193"
  #input = "389125467" # test input
  maxCup = 9'i8
  minCup = 1'i8

type GameState = object
  cups: DoublyLinkedRing[int8]
  cur: DoublyLinkedNode[int8]

func `$`(g: GameState): string =
  for e in g.cups:
    if e == g.cur.value:
      result.add fmt"({e}) "
    else:
      result.add $e & " "
  result = result[0..^2]

func parseinput(text: string): GameState =
  result.cups = initDoublyLinkedRing[int8]()
  for ch in text:
    result.cups.append ($ch).parseInt.int8
  result.cur = result.cups.head

proc insertAfter[T](node: var DoublyLinkedNode[T], val: T) =
  var newNode = newDoublyLinkedNode[T](val)
  newNode.prev = node
  newNode.next = node.next
  node.next.prev = newNode
  node.next = newNode

proc playRound(game: var GameState) =
  var pickedCups: seq[int8]
  for i in 0..2:
    pickedCups.add game.cur.next.value
    game.cups.remove game.cur.next

  var
    destTarget = game.cur.value
    dest: DoublyLinkedNode[int8]
  while dest.isNil:
    destTarget.dec
    if destTarget < minCup: destTarget = maxCup
    dest = game.cups.find destTarget

  while pickedCups.len > 0:
    dest.insertAfter(pickedCups.pop)

  game.cur = game.cur.next

func finalScore(g: GameState): string =
  let one = g.cups.find(1'i8)
  var cur = one.next
  while cur != one:
    result = result & $cur.value
    cur = cur.next

var game = input.parseinput
for i in 0..99: game.playRound
let pt1 = game.finalScore
echo pt1
doAssert pt1 == "43769582"
