import strutils, sequtils, deques, regex

type
  Deck = Deque[uint8]
  GameState = tuple[p1, p2: Deck]

func parseInput(text: string): GameState =
  var
    playerIdx = -1
    m: RegexMatch
    decks = newSeqWith(2, initDeque[uint8](text.countLines))
  for line in text.strip.splitLines:
    if line.match(re"Player (\d):", m):
      playerIdx = m.group(0, line)[0].parseInt - 1
    elif line.match(re"\d+"):
      decks[playerIdx].addLast line.parseInt.uint8
    else:
      assert line.strip.len == 0
  result.p1 = decks[0]
  result.p2 = decks[1]

proc playRound(game: var GameState): bool =
  if game.p1.len == 0 or game.p2.len == 0:
    return false

  let
    p1card = game.p1.popFirst
    p2card = game.p2.popFirst
  assert p1card != p2card
  if p1card > p2card:
    game.p1.addLast p1card
    game.p1.addLast p2card
  else:
    game.p2.addLast p2card
    game.p2.addLast p1card
  return true

func getScore(game: GameState): int =
  let winningDeck = if game.p1.len >= game.p2.len: game.p1 else: game.p2
  for (i, card) in winningDeck.pairs:
    result.inc card.int * (winningDeck.len - i)

proc playUntilFinished(game: var GameState): int =
  while game.playRound: discard
  return game.getScore

let inputDecks = readFile("./input/day22_input.txt").parseInput

var pt1Game = inputDecks
let pt1 = pt1Game.playUntilFinished
echo pt1
doAssert pt1 == 32199
