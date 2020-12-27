import strutils, deques, regex, sets, hashes

# Warning: slow, runs in about 67 s on my machine

type
  Player = enum p1, p2
  Deck = Deque[uint8]
  GameState = array[Player, Deck]
  GameResult = object
    score: int
    winner: Player

func parseInput(text: string): GameState =
  var
    curPlayer: Player
    m: RegexMatch
  for line in text.strip.splitLines:
    if line.match(re"Player (\d):", m):
      curPlayer = block:
        var i = m.group(0, line)[0].parseInt
        assert i in {1, 2}
        if i == 1: p1 else: p2
    elif line.match(re"\d+"):
      result[curPlayer].addLast line.parseInt.uint8
    else:
      assert line.strip.len == 0

func isFinished(game: GameState): bool =
  game[p1].len == 0 or game[p2].len == 0

proc playRound(game: var GameState): bool =
  if game.isFinished:
    return false

  let cardsInPlay: array[Player, uint8] = [game[p1].popFirst, game[p2].popFirst]
  assert cardsInPlay[p1] != cardsInPlay[p2]
  let winner = if cardsInPlay[p1] > cardsInPlay[p2]: p1 else: p2
  game[winner].addLast cardsInPlay.max
  game[winner].addLast cardsInPlay.min
  return true

func getScore(deck: Deck): int =
  for (i, card) in deck.pairs:
    result.inc card.int * (deck.len - i)

proc playUntilFinished(game: var GameState): GameResult =
  while game.playRound: discard
  result.winner = if game[p1].len >= game[p2].len: p1 else: p2
  result.score = game[result.winner].getScore

let inputDecks = readFile("./input/day22_input.txt").parseInput

var pt1Game = inputDecks
let pt1 = pt1Game.playUntilFinished.score
echo pt1
doAssert pt1 == 32199

# Part 2
func hash(d: Deck): Hash =
  var h: Hash
  for card in d: h = h !& card.int
  result = !$h

func copyFirstN[T](d: Deque[T], n: Natural): Deque[T] =
  result = initDeque[T](n)
  for i in 0..<n:
    result.addLast d[i]
  assert result.len == n
  assert d.peekFirst == result[0]
  assert d[n - 1] == result.peekLast

proc playGame2(game: var GameState): GameResult =
  var roundsPlayed: HashSet[GameState]
  while not game.isFinished:
    if game in roundsPlayed:
      return GameResult(winner: p1, score: game[p1].getScore)
    roundsPlayed.incl game

    let cards: array[Player, uint8] = [game[p1].popFirst, game[p2].popFirst]
    assert cards[p1] != cards[p2]

    let winner =
      if game[p1].len >= cards[p1].int and game[p2].len >= cards[p2].int:
        var subgame: GameState = [
          game[p1].copyFirstN(cards[p1]),
          game[p2].copyFirstN(cards[p2]),
        ]
        subgame.playGame2.winner
      else:
        if cards[p1] > cards[p2]: p1 else: p2

    let loser = if winner == p1: p2 else: p1
    game[winner].addLast cards[winner]
    game[winner].addLast cards[loser]

  result.winner = if game[p1].len >= game[p2].len: p1 else: p2
  result.score = game[result.winner].getScore

var pt2game = inputDecks
echo pt2game.playGame2
