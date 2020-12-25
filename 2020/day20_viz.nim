import nico, day20, strformat, os, strutils

let assemTiles = system.readFile("./input/day20_input.txt")
  .parseInput.assembleTiles

let satImage = assemTiles.toImage

var
  (monsterCount, monstersImage) = satImage.findMonsters()
  choppyCount = monstersImage.countChoppy

type DrawState {.pure.} = enum Tiles, Image, Monsters

type p8Color {.pure.} = enum
  Black = 0
  DarkBlue = 1
  DarkPurple = 2
  DarkGreen = 3
  Brown = 4
  DarkGrey = 5
  LightGrey = 6
  White = 7
  Red = 8
  Orange = 9
  Yellow = 10
  Green = 11
  Blue = 12
  Lavender = 13
  Pink = 14
  LightPeach = 15

var drawState = DrawState.Tiles

func resetAndFindMonsters(img: Image): (int, Image) =
  var newImg: Image
  for row in img:
    newImg.add row.replace("O", "#")
  newImg.findMonsters()

func toColor(c: char): int =
  let palcol = case c:
  of '.': p8Color.DarkBlue
  of '#': p8Color.LightGrey
  of 'O': p8Color.Yellow
  else: p8Color.Pink
  palCol.int

proc drawTile(t: Tile, x, y: int) =
  for i, row in t.pixels.pairs:
    for j, c in row:
      setColor(c.toColor)
      pset(x+j, y+i)

proc drawTileMatrix(tm: TileMatrix) =
  for i, row in assemTiles:
    for j, t in row:
      drawTile(t, j*(tileSize + 1), i*(tileSize + 1))

proc drawImage(img: Image) =
  for (i, row) in img.pairs:
    for (j, c) in row.pairs:
      setColor(c.toColor)
      pset(j, i)

  setColor p8Color.White.int
  let (mousex, mousey) = mouse()
  print(fmt"Row: {mousey} Col: {mousex}", 5, 100)
  if drawState == DrawState.Monsters:
    print(fmt"Monsters: {monsterCount} Choppy: {choppyCount}", 5, 107)

proc gameInit() =
  loadPalettePico8().setPalette
  loadFont(0, "font.png")

proc gameUpdate(dt: float32) =
  if btnp(pcA):
    if drawState == DrawState.high:
      drawState = DrawState.low
    else:
      drawState = drawState.succ

  if btnp(pcRight):
    (monsterCount, monstersImage) = monstersImage.rotatecw.resetAndFindMonsters
    choppyCount = monstersImage.countChoppy
  sleep(20)

proc gameDraw() =
  #printc("hello world", screenWidth div 2, screenHeight div 2)
  cls()
  case drawState:
  of DrawState.Tiles:
    drawTileMatrix(assemTiles)
  of DrawState.Image:
    drawImage(satImage)
  of DrawState.Monsters:
    drawImage(monstersImage)
  sleep(20)


nico.init("auxym", "AOC 2020 Day 20")
nico.createWindow("AOC 2020 Day 20", 130, 130, 8, false)
nico.run(gameInit, gameUpdate, gameDraw)
