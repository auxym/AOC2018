import strutils, sequtils, regex, tables, utils, hashes

const tileSize = 10

type Pixel = char
type PixelList = array[tileSize, Pixel]
type Tile = object
  pixels: array[tileSize, PixelList]
  id: int

type PixelListAnyDir = distinct PixelList
type BorderKind = enum Top, Bottom, Left, Right

type BorderId = tuple[tileId: int, kind: BorderKind]

type BorderTable = Table[PixelListAnyDir, seq[BorderId]]

func reversed(a: PixelList): PixelList =
  for (i, elem) in a.pairs:
    result[a.high - i] = elem

func hash(b: PixelListAnyDir): int =
  let
    p = b.PixelList.join("")
    pr = b.PixelList.reversed.join("")
  if p < pr: hash(p) else: hash(pr)

func `==`(a, b: PixelListAnyDir): bool =
  a.PixelList == b.PixelList or a.PixelList == b.PixelList.reversed

func toPixelList(s: string): array[tileSize, Pixel] =
  for i in 0..result.high:
    result[i] = s[i]

func getBorder(t: Tile, which: BorderKind): PixelList =
  case which:
  of Top:
    result = t.pixels[0]
  of Bottom:
    result = t.pixels[t.pixels.high]
  of Left:
    for (i, row) in t.pixels.pairs:
      result[i] = row[0]
  of Right:
    for (i, row) in t.pixels.pairs:
      result[i] = row[^1]

iterator allBorders(t: Tile): PixelList =
  for bk in BorderKind: yield t.getBorder(bk)

func parseInput(text: string): seq[Tile] =
  var
    m: RegexMatch
    rowIdx: int = 99
    curTile: Tile
  for line in text.splitLines:
    if line.match(re"Tile (\d+):", m):
      curTile = Tile(id: m.group(0, line)[0].parseInt)
      rowIdx = 0
    elif rowIdx < tileSize:
      curTile.pixels[rowIdx] = line.toPixelList
      inc rowIdx
      if rowIdx == tileSize:
        result.add curTile

func createBorderTable(tiles: seq[Tile]): BorderTable =
  for t in tiles:
    for bk in BorderKind:
      let
        bdPixels = t.getBorder(bk).PixelListAnyDir
        bdId: BorderId = (t.id, bk)
      if bdPixels in result:
        result[bdPixels].add bdId
      else:
        result[bdPixels] = @[bdId]

func findCornerTiles(tiles: seq[Tile]): seq[Tile] =
  let bdtab = tiles.createBorderTable
  for t in tiles:
    var tBorderMatches = 0
    for bd in t.allBorders:
      assert bdtab[bd.PixelListAnyDir].len in (1..2)
      if bdtab[bd.PixelListAnyDir].len == 2: inc tBorderMatches
    assert tBorderMatches in (2..4)
    if tBorderMatches == 2: result.add t

let
  allTiles = readFile("./input/day20_input.txt").parseInput
  cornerTiles = allTiles.findCornerTiles

assert cornerTiles.len == 4
let pt1 = cornerTiles.mapIt(it.id).foldl(a*b)
echo pt1
doAssert pt1 == 7492183537913
