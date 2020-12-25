import strutils, sequtils, regex, tables, utils, hashes, math, algorithm

const tileSize* = 10

type Pixel* = char
type PixelList* = array[tileSize, Pixel]
type Tile* = object
  pixels*: array[tileSize, PixelList]
  id*: int16

type PixelListAnyDir = distinct PixelList
type BorderKind = enum Top, Bottom, Left, Right

type BorderId = tuple[tileId: int16, kind: BorderKind]

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

func parseInput*(text: string): Table[int, Tile] =
  var
    m: RegexMatch
    rowIdx: int = 99
    curTile: Tile
  for line in text.splitLines:
    if line.match(re"Tile (\d+):", m):
      curTile = Tile(id: m.group(0, line)[0].parseInt.int16)
      rowIdx = 0
    elif rowIdx < tileSize:
      curTile.pixels[rowIdx] = line.toPixelList
      inc rowIdx
      if rowIdx == tileSize:
        result[curTile.id] = curTile

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


# Part 2

type TileMatrix* = seq[seq[Tile]]
type Image* = seq[string]
type Coords = tuple[i, j: int]

func isFreeEdge(pxs: PixelList, tab: BorderTable): bool =
  tab[pxs.PixelListAnyDir].len == 1

func flipv(t: Tile): Tile =
  result.id = t.id
  for (i, row) in t.pixels.pairs:
    result.pixels[t.pixels.high - i] = row

func fliph(t: Tile): Tile =
  result.id = t.id
  for (i, row) in t.pixels.pairs:
    result.pixels[i] = row.reversed

func rotatecw(t: Tile): Tile =
  result.id = t.id
  let hi = t.pixels.high
  for i in 0..hi:
    for j in 0..hi:
      result.pixels[j][hi - i] = t.pixels[i][j]

func flipv*(img: Image): Image =
  result = img
  for (i, row) in img.pairs:
    result[img.high - i] = row

func fliph*(img: Image): Image =
  result = img
  for (i, row) in img.pairs:
    result[i] = toSeq(row).reversed.join("")

func rotatecw*(img: Image): Image =
  result = img
  let hi = img.high
  for i in 0..hi:
    for j in 0..hi:
      result[j][hi - i] = img[i][j]

func orientToMatch(t: Tile, matchingBd: BorderKind, target: PixelList): Tile =
  result = t
  for i in 0..3:
    if result.getBorder(matchingBd) == target: return result
    if result.flipv.getBorder(matchingBd) == target: return result.flipv
    result = result.rotatecw
  raise newException(ValueError, "Could not match border")

func assembleTiles*(tiles: Table[int, Tile]): seq[seq[Tile]] =
  let
    bdtab = toSeq(tiles.values).createBorderTable
    cornerTiles = toSeq(tiles.values).findCornerTiles
    imgSize = sqrt(tiles.len.float).toInt

  let upperLeft = block:
    var ul = cornerTiles[0]
    if not ul.getBorder(Top).isFreeEdge(bdtab): ul = ul.flipv
    if not ul.getBorder(Left).isFreeEdge(bdtab): ul = ul.fliph
    assert ul.getBorder(Left).isFreeEdge(bdtab)
    assert ul.getBorder(Top).isFreeEdge(bdtab)
    ul

  result = newSeqWith(imgSize, newSeq[Tile](imgSize))

  var
    tileToMatch: Tile
    bdToMatch: PixelList
    bdMatching: BorderKind
  for i, row in result.mpairs:
    for j in 0..row.high:
      if (i, j) == (0, 0):
        row[0] = upperLeft
        continue
      elif j == 0:
        tileToMatch = result[i - 1][j]
        bdToMatch = tileToMatch.getBorder(Bottom)
        bdMatching = Top
      else:
        tileToMatch = result[i][j - 1]
        bdToMatch = tileToMatch.getBorder(Right)
        bdMatching = Left

      let matchingTile = block:
        let matchingTileList = bdtab[bdToMatch.PixelListAnyDir]
          .filterIt(it.tileId != tileToMatch.id)
        assert matchingTileList.len == 1
        tiles[matchingTileList[0].tileId]
      row[j] = matchingTile.orientToMatch(bdMatching, bdToMatch)

func toImage*(tm: TileMatrix): Image =
  let imgSize = tm.len * (tileSize - 2)
  result = newSeqWith(imgSize, repeat('X', imgSize))
  var i, j = 0
  for tileRowIdx, tRow in tm.pairs:
    for tileColIdx, t in tRow.pairs:
      i = tileRowIdx * (tileSize - 2)
      for cRow in t.pixels[1..^2]:
        j = tileColIdx * (tileSize - 2)
        for c in cRow[1..^2]:
          result[i][j] = c
          inc j
        inc i

  assert i == imgSize
  assert j == imgSize

func parseMonster(text: string): seq[Coords] =
  let monsterLines = text.splitLines.filterIt(it.len > 0)
  assert monsterLines.len == 3
  assert monsterLines.allIt(it.len == 20)

  for i, line in monsterLines:
    for j, c in line:
      if c == '#': result.add (i, j)

const monster = """
                  # 
#    ##    ##    ###
 #  #  #  #  #  #   
""".parseMonster
const
  monsterHeight = 3
  monsterWidth = 20

func findMonsters*(img: Image): (int, Image) =
  var
    monsterCount = 0
    newImg = img
  for i in 0..(img.len - monsterHeight):
    for j in 0..(img[0].len - monsterWidth):
      var foundMonster = true
      for coord in monster:
        if img[i+coord.i][j+coord.j] != '#':
          foundMonster = false
          break

      if foundMonster:
        inc monsterCount
        for coord in monster:
          newImg[i+coord.i][j+coord.j] = 'O'

  (monsterCount, newImg)

func orientAndFindMonsters*(img: Image): (int, Image) =
  var
    newImg: Image
    monsterCount: int
    orientedImg: Image = img
  for i in 0..3:
    (monsterCount, newImg) = orientedImg.findMonsters
    if monsterCount > 0: return (monsterCount, newImg)

    (monsterCount, newImg) = orientedImg.fliph.findMonsters
    if monsterCount > 0: return (monsterCount, newImg)

    orientedImg = orientedImg.rotatecw

  raise newException(ValueError, "No monsters found")

func countChoppy*(img: Image): int =
  for line in img: result.inc line.count('#')

when isMainModule:
  let
    allTiles = readFile("./input/day20_input.txt").parseInput
    cornerTiles = toSeq(allTiles.values).findCornerTiles

  assert cornerTiles.len == 4
  let pt1 = cornerTiles.mapIt(it.id.int).foldl(a*b)
  echo pt1
  doAssert pt1 == 7492183537913

  let
    assembled = allTiles.assembleTiles
    cleanImage = assembled.toImage
    (monsterCount, monsterImg) = cleanImage.orientAndFindMonsters
    pt2 = monsterImg.countChoppy

  echo pt2
  doAssert pt2 == 2323
