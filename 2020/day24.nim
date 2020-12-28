import tables, sequtils, strutils

type HexAxialCoords = tuple[q, r: int]

type HexDirection = enum
  hdEast = "e"
  hdWest = "w"
  hdSouthEast = "se"
  hdSouthWest = "sw"
  hdNorthEast = "ne"
  hdNorthWest = "nw"

type Path = seq[HexDirection]

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

func moveTo(start: HexAxialCoords, path: Path): HexAxialCoords =
  result = start
  for step in path: result = result + step.toVector

assert Origin.moveTo("nwwswee".tokenizeSteps) == Origin
assert Origin.moveTo("esew".tokenizeSteps) == hdSouthEast.toVector

let inputPaths = readFile("./input/day24_input.txt")
  .strip.splitLines.map(tokenizeSteps)

func flipTilesAndCount(paths: seq[Path]): Natural =
  var tileMap: Table[HexAxialCoords, bool]
  for pt in paths:
    let
      dest = Origin.moveTo(pt)
      cur = tileMap.getOrDefault(dest, false)
    tileMap[dest] = not cur
  for t in tileMap.values:
    if t: inc result

echo inputPaths.flipTilesAndCount
