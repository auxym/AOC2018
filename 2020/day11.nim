import strutils, sequtils

type
  Cell = enum clFloor, clEmpty, clOccupied
  Layout = seq[seq[Cell]]
  Coords = tuple[r, c: int]

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

func isPositionValid(l: Layout, pos: Coords): bool =
  return pos.r >= 0 and pos.r <= l.high and pos.c >= 0 and pos.c <= l[0].high

func countOccupiedAround(ly: Layout, cd: Coords): int =
  result = 0
  let
    relsur = @[(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (1, 1), (-1, 1), (-1, -1)]
    surround = relsur.mapIt((cd.r + it[0], cd.c + it[1]))
  for pos in surround:
    if ly.isPositionValid(pos) and ly[pos] == clOccupied:
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

let testlayout = """
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
""".parseLayout

let seatingLayout = readFile("./input/day11_input.txt").parseLayout

let pt1 = seatingLayout.advanceUntilStationary.countOccupied
doAssert pt1 == 2247
echo pt1