import utils, tables, regex, strutils, sequtils, sets

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


func getInvalidVals(ranges: seq[FieldRange], t: Ticket): seq[int] =
  t.filterIt(not isInAnyRange(ranges, it))


func getErrorRate(inp: Input): int =
  let allRanges = toSeq(toSeq(inp.ranges.values).chain)
  for t in inp.nearbyTickets:
    for x in allRanges.getInvalidVals(t):
      result.inc x


let pinput = readFile("./input/day16_input.txt").parseInput

# Part 1
let pt1 = pinput.getErrorRate
echo pt1
doAssert pt1 == 26053

# Part 2

func isValidTicket(t: Ticket, rangetab: FieldRangeTable): bool =
  let allRanges = toSeq(toSeq(rangetab.values).chain)
  return allRanges.getInvalidVals(t).len == 0


func getFieldMap(inp: Input): Table[string, int] =
  let
    validTickets = inp.nearbyTickets.filterIt(it.isValidTicket(inp.ranges))
    ticketSize = validTickets[0].len
    fieldNames = toSeq(inp.ranges.keys).toHashSet

  var
    fieldNameSets = newSeqWith(ticketSize, fieldNames)
    foundStack: seq[string]

  for ticket in validTickets:
    for (i, val) in ticket.pairs:
      for name in fieldNames:
        if name notin fieldNameSets[i]: continue
        if not isInAnyRange(inp.ranges[name], val):
          fieldNameSets[i].excl name

      if fieldNameSets[i].len == 1:
        let fname = fieldNameSets[i].pop()
        foundStack.add fname
        result[fname] = i

  while foundStack.len > 0:
    let curName = foundStack.pop()
    for (i, nameset) in fieldNameSets.mpairs:
      nameset.excl curName
      if nameset.len == 1:
        let fname = nameset.pop()
        foundStack.add fname
        result[fname] = i

  assert result.len == ticketSize

func getPt2(ticket: Ticket, fieldMap: Table[string, int]): int =
  result = 1
  for (fieldName, fieldIndex) in fieldMap.pairs:
    if fieldName.startsWith("departure"):
      result = result * ticket[fieldIndex]

let fieldMap = pinput.getFieldMap
let pt2 = pinput.myTicket.getPt2(fieldMap)
echo pt2
doAssert pt2 == 1515506256421
