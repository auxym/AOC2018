import utils, tables, regex, strutils, sequtils, strformat

type
  Ticket = seq[int]
  FieldRange = HSlice[int, int]
  FieldRangeTable = Table[string, seq[FieldRange]]

type Input = object
  myTicket: Ticket
  nearbyTickets: seq[Ticket]
  ranges: FieldRangeTable


func parseInput(text: string): Input =
  let blocks = text.strip.split("\n\n")
    .mapIt(toSeq(it.splitLines))
  assert blocks.len == 3

  for line in blocks[0]:
    var m: RegexMatch
    doAssert line.match(re"([a-z ]+): (\d+)-(\d+) or (\d+)-(\d+)", m)
    let
      fieldName = m.group(0, line)[0]
      a1 = m.group(1, line)[0].parseInt
      a2 = m.group(2, line)[0].parseInt
      b1 = m.group(3, line)[0].parseInt
      b2 = m.group(4, line)[0].parseInt
    result.ranges[fieldName] = @[(a1..a2), (b1..b2)]

  result.myTicket = blocks[1][1].getInts

  for line in blocks[2][1..^1]:
    result.nearbyTickets.add line.getInts


func isInAnyRange(ranges: seq[FieldRange], i: int): bool =
  ranges.anyIt(it.contains(i))


func getErrorRate(inp: Input): int =
  let allRanges = toSeq(toSeq(inp.ranges.values).chain)
  for x in chain(inp.nearbyTickets):
    if not isInAnyRange(allRanges, x):
      result.inc x


let pinput = readFile("./input/day16_input.txt").parseInput
when false:
  for (fn, r) in pinput.ranges.pairs: echo fmt"{fn}: {r}"
  echo ""
  echo fmt"My ticket: {pinput.myTicket}" & "\n"
  for t in pinput.nearbyTickets: echo t

# Part 1
let pt1 = pinput.getErrorRate
echo pt1
doAssert pt1 == 26053
