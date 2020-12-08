import regex, sequtils, strutils, algorithm, tables

type
  Compass* = enum North, East, South, West
  WeightedEdge*[T] = tuple[elem: T, weight: int]
  WeightedAdjList*[T] = TableRef[T, Table[T, int]]

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

func newWeightedAdjList*[T](initialSize = 0): WeightedAdjList[T] =
  if initialSize <= 0:
    newTable[T, Table[T, int]]()
  else:
    newTable[T, Table[T, int]](initialSize)

func addEdge*[T](g: var WeightedAdjList[T], frm: T, to: T, weight: int = 1) =
  if frm notin g:
    g[frm] = {to: weight}.toTable
  else:
    g[frm][to] = weight

func addNode*[T](g: var WeightedAdjList[T], node: T) =
  if node notin g: g[node] = newSeq[WeightedEdge[T]]().toTable

iterator traverseDfs*[T](g: WeightedAdjList[T], start: T): WeightedEdge[T] =
  var
    stack: seq[WeightedEdge[T]]
    cur: WeightedEdge[T]
  stack.add (start, 0)
  while stack.len > 0:
    cur = stack.pop
    yield cur
    if cur.elem notin g: continue
    for (elem, wt) in g[cur.elem].pairs:
      stack.add (elem, wt)

export
  tables.contains,
  tables.hasKey,
  tables.keys, tables.values, tables.pairs,
  tables.`[]=`,
  tables.`[]`
