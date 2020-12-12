import utils, regex, strutils

type Ship = object
  heading: Vector
  location: Vector
  waypoint: Vector

func toVector(x: char): Vector =
  case x
  of 'N': (0, 1)
  of 'E': (1, 0)
  of 'W': (-1, 0)
  of 'S': (0, -1)
  else:
    raise newException(ValueError, "Invalid char: " & x)

func parseAction(text: string): (char, int) =
  const actionpattern = re"([NSEWLRF])(\d+)"
  var m: RegexMatch
  doAssert text.match(actionpattern, m)
  let
    actionkind: char = m.group(0, text)[0][0]
    actionval: int = m.group(1, text)[0].parseInt
  (actionkind, actionval)

proc doAction(s: var Ship, act: string) =
  let (actionkind, actionval) = parseAction(act)
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
      s.location = s.location + (actionval * s.heading)
    else:
      discard

let actionList = readfile("./input/day12_input.txt").strip.splitLines

# Part1

var ship1 = Ship(heading: (1, 0), location: (0, 0))
for a in actionList:
  ship1.doAction a
let pt1 = ship1.location.manhattan((0, 0))
doAssert pt1 == 508
echo pt1

# Part 2

proc doAction2(s: var Ship, act: string) =
  let (actionkind, actionval) = parseAction(act)
  case actionkind
    of {'N', 'S', 'E', 'W'}:
      s.waypoint = s.waypoint + (actionval * actionkind.toVector)
    of 'R':
      for i in 1..(actionval div 90):
        s.waypoint = s.waypoint.cw
    of 'L':
      for i in 1..(actionval div 90):
        s.waypoint = s.waypoint.ccw
    of 'F':
      s.location = s.location + (actionval * s.waypoint)
    else:
      discard

var ship2 = Ship(location: (0, 0), waypoint: (10, 1))
for a in actionList:
  ship2.doAction2 a
let pt2 = ship2.location.manhattan((0, 0))
doAssert pt2 == 30761
echo pt2