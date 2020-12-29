import tables, sequtils, strutils

type HexDirection = enum
  hdEast = "e"
  hdWest = "w"
  hdSouthEast = "se"
  hdSouthWest = "sw"
  hdNorthEast = "ne"
  hdNorthWest = "nw"

type
  Path = seq[HexDirection]
  HexAxialCoords = tuple[q, r: int]
  TileMap = Table[HexAxialCoords, bool]

const Origin: HexAxialCoords = (0, 0)

func `+`(a, b: HexAxialCoords): HexAxialCoords =
  (a.q + b.q, a.r+b.r)

func toVector(dir: HexDirection): HexAxialCoords =
  case dir
  of hdEast: (1, 0)
  of hdWest: (-1, 0)
  of hdSouthEast: (0, 1)
  of hdSouthWest: (-1, 1)
  of hdNorthEast: (1, -1)
  of hdNorthWest: (0, -1)

func tokenizeSteps(text: string): Path =
  var cur = 0
  while cur <= text.high:
    let chr = text[cur]
    case chr
    of {'e', 'w'}:
      result.add parseEnum[HexDirection]($chr)
      cur.inc
    of {'s', 'n'}:
      result.add parseEnum[HexDirection](text[cur..cur + 1])
      cur.inc 2
    else: assert false

assert "nwwswee".tokenizeSteps == @[hdNorthWest, hdWest, hdSouthWest, hdEast, hdEast]
assert "esew".tokenizeSteps == @[hdEast, hdSouthEast, hdWest]

func moveTo(start: HexAxialCoords, path: openArray[HexDirection]): HexAxialCoords =
  result = start
  for step in path: result = result + step.toVector

assert Origin.moveTo("nwwswee".tokenizeSteps) == Origin
assert Origin.moveTo("esew".tokenizeSteps) == hdSouthEast.toVector

func countBlack(tiles: TileMap): Natural =
  for t in tiles.values:
    if t: inc result

func flipTilesAndCount(paths: seq[Path]): (TileMap, Natural) =
  var tileMap: TileMap
  for pt in paths:
    let
      dest = Origin.moveTo(pt)
      cur = tileMap.getOrDefault(dest, false)
    tileMap[dest] = not cur
  result = (tileMap, tileMap.countBlack)


let inputPaths = readFile("./input/day24_input.txt")
  .strip.splitLines.map(tokenizeSteps)

let (tileMap, pt1Count) = inputPaths.flipTilesAndCount
echo pt1Count
doAssert pt1Count == 341

# Part 2
iterator neighbors(c: HexAxialCoords): HexAxialCoords =
  for d in HexDirection:
    yield c.moveTo [d]

func evolve(tiles: TileMap): TileMap =
  var stack = toSeq(tiles.keys)

  while stack.len > 0:
    let
      t = stack.pop()
      tileState = tiles.getOrDefault(t, false)
    var nbcountBlack = 0
    for nb in t.neighbors:
      if tiles.getOrDefault(nb, false):
        inc nbcountBlack
      if tileState and nb notin tiles:
        stack.add nb

    if tileState and (nbCountBlack == 0 or nbCountBlack > 2):
      result[t] = false
    elif not tileState and nbcountBlack == 2:
      result[t] = true
    else:
      result[t] = tileState

var artExhibit = tileMap
for i in 1..100:
  artExhibit = artExhibit.evolve
let pt2 = artExhibit.countBlack
echo pt2
doAssert pt2 == 3700
