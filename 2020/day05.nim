import strutils, sequtils

func getRowOrCol(chars: string): int =
  result = 0
  for i, c in chars.pairs:
    result = result shl 1
    if c in {'B', 'R'}:
      result = result or 1

func getSeatId(text: string): int =
  doAssert text.len == 10
  let
    row = getRowOrCol(text[0..6])
    col = getRowOrCol(text[7..9])
  row * 8 + col

doAssert getRowOrCol("FBFBBFF") == 44
doAssert getRowOrCol("RLR") == 5

let passes = readFile("./input/day05_input.txt").strip.splitLines

var highestId = int.low
for id in passes.map(getSeatId):
  if id > highestId: highestId = id
echo highestId
doAssert highestId == 970