import strutils, sequtils, intsets

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

let passIds = readFile("./input/day05_input.txt")
  .strip
  .splitLines
  .map(getSeatId)
  .toIntSet

# Part 1
var highestId = int.low
for id in passIds:
  if id > highestId: highestId = id
echo highestId
doAssert highestId == 970

# Part 2
let maxId = 127 * 8 + 7
var missingIds = initIntSet()
for i in countup(0, maxId):
  if i notin passIds:
    missingIds.incl i

for id in missingIds:
  if id == 0 or id == maxId:
    continue
  if (id - 1) in missingIds or (id + 1) in missingIds:
    continue
  echo id