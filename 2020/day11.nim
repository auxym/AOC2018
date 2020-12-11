import strutils, sequtils

type
  Cell = enum clFloor, clEmpty, clOccupied
  Layout = seq[seq[Cell]]
  Coords = tuple[r, c: int]

const allDirections: array[8, Coords] = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (1, 1), (-1, 1), (-1, -1)]

func parseLayout(text: string): Layout =
  var layoutRow: seq[Cell]
  for line in text.strip.splitLines:
    layoutRow = @[]
    for c in line:
      let state: Cell = case c:
        of '#': clOccupied
        of '.': clFloor
        of 'L': clEmpty
        else: raise newException(ValueError, "Unknown char " & c)
      layoutRow.add state
    result.add layoutrow

func `[]`(l: Layout, r, c: int): Cell =
  l[r][c]

func `[]`(l: Layout, cd: Coords): Cell =
  l[cd.r][cd.c]

proc `[]=`(l: var Layout, r, c: int, val: Cell) =
  l[r][c] = val

proc `[]=`(l: var Layout, cd: Coords, val: Cell) =
  l[cd.r][cd.c] = val

func `+`(a, b: Coords): Coords =
  (a.r + b.r, a.c + b.c)

iterator items(l: Layout): Cell =
  for row in system.items(l):
    for c in row: yield c

iterator rows(l: Layout): seq[Cell] =
  for row in system.items(l): yield row

iterator pairs(l: Layout): (Coords, Cell) =
  for irow in 0..l.high:
    for icol in 0..l[irow].high:
      yield ((irow, icol), l[irow, icol])

func copy(l: Layout): Layout =
  for row in l.rows: result.add row

func isValidSeat(l: Layout, pos: Coords): bool =
  return pos.r >= 0 and pos.r <= l.high and pos.c >= 0 and pos.c <= l[0].high

func countOccupiedAround(ly: Layout, cd: Coords): int =
  result = 0
  let surround = allDirections.mapIt((cd.r + it[0], cd.c + it[1]))
  for pos in surround:
    if ly.isValidSeat(pos) and ly[pos] == clOccupied:
      inc result

func countOccupied(ly: Layout): int =
  for c in ly:
    if c == clOccupied: inc result

func advance(ly: Layout): (Layout, int) =
  var
    rlayout: Layout
    numChanges: int = 0
  rlayout = ly.copy

  for (pos, cur) in ly.pairs:
    let nOcc = ly.countOccupiedAround(pos)
    if cur == clEmpty and nOcc == 0:
      rlayout[pos] = clOccupied
      inc numChanges
    elif cur == clOccupied and nOcc >= 4:
      rlayout[pos] = clEmpty
      inc numChanges
  result = (rlayout, numChanges)

func advanceUntilStationary(l: Layout): Layout =
  var numchanges = 1
  result = l.copy
  while numchanges > 0:
    (result, numchanges) = result.advance

let seatingLayout = readFile("./input/day11_input.txt").parseLayout

let pt1 = seatingLayout.advanceUntilStationary.countOccupied
doAssert pt1 == 2247
echo pt1

# Part 2

func lookInDirection(ly: Layout, seat: Coords, dir: Coords): bool =
  # true if person in `seat` can see an occupied seat in direction `dir`
  var cur = seat + dir
  result = false
  while ly.isValidSeat(cur) and ly[cur] == clFloor:
    cur = cur + dir
  if ly.isValidSeat(cur):
    return ly[cur] == clOccupied

func countOccupiedAllDirections(ly: Layout, seat: Coords): int =
  for dir in allDirections:
    if ly.lookInDirection(seat, dir): inc result

func advance2(ly: Layout): (Layout, int) =
  var
    rlayout: Layout
    numChanges: int = 0
  rlayout = ly.copy

  for (pos, cur) in ly.pairs:
    let nOcc = ly.countOccupiedAllDirections(pos)
    if cur == clEmpty and nOcc == 0:
      rlayout[pos] = clOccupied
      inc numChanges
    elif cur == clOccupied and nOcc >= 5:
      rlayout[pos] = clEmpty
      inc numChanges
  result = (rlayout, numChanges)

func advanceUntilStationary2(l: Layout): Layout =
  var numchanges = 1
  result = l.copy
  while numchanges > 0:
    (result, numchanges) = result.advance2

let pt2 = seatingLayout.advanceUntilStationary2.countOccupied
doAssert pt2 == 2011
echo pt2