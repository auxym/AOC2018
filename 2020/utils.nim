import regex, sequtils, strutils, algorithm, sets, tables

type
  Compass* = enum North, East, South, West
  AdjList*[T] = TableRef[T, HashSet[T]]

func cw*(c: Compass): Compass =
  if c == Compass.high:
    Compass.low
  else:
    c.succ

func ccw*(c: Compass): Compass =
  if c == Compass.low:
    Compass.high
  else:
    c.pred

func getInts*(s: string): seq[int] =
  let expint = re"-?\d+"
  result = s.findAndCaptureAll(expint).map(parseInt)

func digits*(i: int): seq[int] =
  result = @[]
  var
    j = i
  while j > 0:
    result.add j mod 10
    j = j div 10
  result = result.reversed

func toBitSet*[T: Ordinal](s: openArray[T]): set[T] =
  for e in s: result.incl e

func toBitSet*(s: string): set[char] =
  for c in s: result.incl c

func newAdjList*[T](initialSize = 0): AdjList[T] =
  if initialSize <= 0:
    newTable[T, HashSet[T]]()
  else:
    newTable[T, HashSet[T]](initialSize)

func dfs*[T](g: AdjList[T], start, target: T): seq[T] =
  var
    stack: seq[seq[T]]
    path: seq[T]
    cur: T
  stack.add @[start]
  while stack.len > 0:
    path = stack.pop
    cur = path[^1]
    if cur == target:
      return path
    elif cur in g:
      for e in g[cur]:
        stack.add path & e
  return @[]

export
  tables.contains,
  tables.hasKey,
  tables.keys, tables.values, tables.pairs,
  tables.`[]=`,
  tables.`[]`
