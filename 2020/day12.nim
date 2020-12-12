import utils, regex, strutils

type Ship = object
  heading: Compass
  location: Vector

const actionpattern = re"([NSEWLRF])(\d+)"

func toVector(x: char): Vector =
  case x
  of 'N': (0, 1)
  of 'E': (1, 0)
  of 'W': (-1, 0)
  of 'S': (0, -1)
  else:
    raise newException(ValueError, "Invalid char: " & x)

proc doAction(s: var Ship, act: string) =
  var m: RegexMatch
  doAssert act.match(actionpattern, m)
  let
    actionkind: char = m.group(0, act)[0][0]
    actionval: int = m.group(1, act)[0].parseInt
  case actionkind
    of {'N', 'S', 'E', 'W'}:
      s.location = s.location + (actionval * actionkind.toVector)
    of 'R':
      for i in 1..(actionval div 90):
        s.heading = s.heading.cw
    of 'L':
      for i in 1..(actionval div 90):
        s.heading = s.heading.ccw
    of 'F':
      s.location = s.location + (actionval * s.heading.toVector)
    else:
      discard

let testActions = """
F10
N3
F7
R90
F11
""".strip.splitLines

let actionList = readfile("./input/day12_input.txt").strip.splitLines

var ship1 = Ship(heading: East, location: (0, 0))
echo ship1
for a in actionList:
  ship1.doAction a
  echo a & " " & $ship1
echo ship1.location.manhattan((0, 0))