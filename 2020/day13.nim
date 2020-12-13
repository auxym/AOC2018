import utils, strutils

let
  inputLines = readFile("./input/day13_input.txt").strip.splitLines
  myDepart = inputLines[0].parseInt
  busPeriods = inputLines[1].getInts

func waitTime(mytime: int, period: int): int =
  period - (mytime mod period)

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