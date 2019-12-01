import strUtils, strscans, seqUtils
import math
import algorithm
import tables
import intsets

type
  Point = tuple[x, y: int]
  State = tuple[pos: Point, vel: Point]

func parseLine(line: string): State =
  var x, y, u, v: int
  const LinePattern = "position=<$s$i,$s$i> velocity=<$s$i,$s$i>"
  if not scanf(line, LinePattern, x, y, u, v):
    raise newException(ValueError, line)
  result = ((x,y), (u, v))

func advance(s: State, seconds=1): State =
  let (x, y) = s.pos
  let (u, v) = s.vel
  result = ((x+(u*seconds), y+(v*seconds)), (u, v))

func advanceMany(states: seq[State], seconds=1): seq[State] =
  for s in states:
    result.add s.advance(seconds)

func cmpStateYX(a, b: State): int =
  result = cmp(a.pos.y, b.pos.y)
  if result == 0:
    result = cmp(a.pos.x, b.pos.x)

proc printImage(dots: seq[State]) =
  let
    sortedDots = dots.sorted(cmpStateYX)
    min_x = dots.foldl(min(a, b.pos.x), int.high)
    max_x = dots.foldl(max(a, b.pos.x), int.low)

  var
    line: string

  for i, d in sortedDots:
    if i == 0 or d.pos.y != sortedDots[i-1].pos.y:
      echo line
      line = repeat(' ', max_x - min_x + 1)
    line[d.pos.x - min_x] = '#'
  echo line

func evalScore(dots: seq[State]): int =
  var
    scores = initTable[int, int](256)
    col = initIntSet()

  let sortedDots = dots.sorted(cmpStateYX)

  for i, dot in sortedDots:
    if i > 0 and sortedDots[i-1].pos.y != dot.pos.y:
      for k in col:
        if scores.contains(k):
          scores[k] += 1
        else:
          scores[k] = 0
      for k in scores.keys:
        if not col.contains(k):
          result += scores[k] ^ 2
          scores.del k
      col.clear()

    col.incl dot.pos.x

  for val in scores.values:
    result += val ^ 2

let input = readFile("./day10_input.txt").strip().splitLines().map(parseLine)

var maxScore, maxScoreTime: int
for time in 1..20_000:
  let 
    ad = input.advanceMany(time)
    score = evalScore(ad)
  if score > maxScore:
    maxScore = score
    maxScoreTime = time

echo maxScoreTime
echo maxScore
printImage(input.advanceMany(maxScoreTime))
