import lists
import seqUtils
import strUtils
import strformat
import strscans

proc insertAfter[T](pos, newNode: var DoublyLinkedNode[T]) =
  newNode.next = pos.next
  newNode.prev = pos
  pos.next.prev = newNode
  pos.next = newNode

proc getNPrev[T](n: DoublyLinkedNode[T], j: int): DoublyLinkedNode[T] =
  result = n
  for i in 0..<j:
    result = result.prev

proc printGame(game: DoublyLinkedRing[int], player: int, current: int) =
  var buf = fmt"[{player:d}]"
  for it in game.nodes:
    if it.value == current:
      buf.add fmt" ({it.value:d})"
    else:
      buf.add fmt" {it.value:d}"
  echo buf

proc play(players: int, last: int): int =
  var
    game = initDoublyLinkedRing[int]()
    player = 0
    scores = newSeq[int](players)
    current, newMarble, toRemove: DoublyLinkedNode[int]

  for i in 0..last:
    newMarble = newDoublyLinkedNode(i)
    if i in {0..1}:
      game.append newMarble
      current = newMarble
    elif i mod 23 == 0:
      toRemove = current.getNPrev(7)
      scores[player] += toRemove.value
      scores[player] += i
      current = toRemove.next
      game.remove(toRemove)
    else:
      current.next.insertAfter(newMarble)
      current = newMarble

    #printGame(game, player, current.value)
    player = (player + 1) mod players

  return max(scores)

var players, last: int
doAssert scanf(
  readFile("day9_input.txt"),
  "$i players; last marble is worth $i points",
  players, last)

echo play(players, last)
echo play(players, last*100)
