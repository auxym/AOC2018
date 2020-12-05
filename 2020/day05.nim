import sequtils, intsets

func toBit(c: char): int =
  if c in {'B', 'R'}: 1 else: 0

func getSeatId(text: string): int =
  for bit in text.map(toBit):
    result = (result shl 1) or bit

doAssert getSeatId("FBFBBFFRLR") == 357

let passIds = toSeq(lines("./input/day05_input.txt")).map(getSeatId).toIntSet

# Part 1
let
  highestId = toSeq(passIds).max
  lowestId = toSeq(passIds).min
echo highestId
doAssert highestId == 970

# Part 2
let
  allSeats = toSeq(lowestId .. highestId).toIntSet
  mySeat = toSeq(allSeats - passIds)[0]

doAssert myseat == 587
echo myseat