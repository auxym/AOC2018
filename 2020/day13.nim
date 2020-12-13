import utils, strutils, sequtils, algorithm, math

let
  inputLines = readFile("./input/day13_input.txt").strip.splitLines
  myDepart = inputLines[0].parseInt
  busPeriods = inputLines[1].getInts

func waitTime(mytime: int, period: int): int =
  (period - (mytime mod period)) mod period

var
  minWait = int.high
  minId: int
for bus in busPeriods:
  if waitTime(myDepart, bus) < minWait:
    minWait = waitTime(myDepart, bus)
    minId = bus
let pt1 = minWait*minId
echo pt1
doAssert pt1 == 5946

# Part 2
type BusDeparture = tuple[id, offset: int]

func parsePt2(line: string): seq[BusDeparture] =
  for (i, elem) in toSeq(line.split(',')).pairs:
    if elem == "x": continue
    result.add (elem.parseInt, i)

# Cheers to u/delventhalz for the hint on this one
# https://www.reddit.com/r/adventofcode/comments/kc5bl5/weird_math_trick_goes_viral/gfp4g79
func findDeparture(targetSched: seq[BusDeparture]): int =
  var
    busStack = targetSched.sorted
    curBus = busStack.pop
    time = -curBus.offset
    increment = curBus.id
  while true:
    time.inc increment
    if (time - (curBus.id - curBus.offset)) mod curBus.id == 0:
      increment = lcm(increment, curBus.id)
      if busStack.len > 0:
        curBus = busStack.pop
      else:
        return time

let targetDepartures = inputLines[1].parsept2
let pt2 = targetDepartures.findDeparture
echo pt2
doAssert pt2 == 645338524823718
