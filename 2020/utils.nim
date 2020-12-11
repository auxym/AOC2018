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

iterator combinations*(n, k: int): seq[int] =
  let hi = n-1
  var
    i: int
    result = toSeq(0..<k)
  yield result
  while true:
    i = k - 1
    if result[i] < hi:
      inc result[i]
    else:
      dec i
      while i >= 0 and result[i] >= (result[i+1] - 1):
        dec i
      if i < 0: break
      inc result[i]
    for j in (i+1..k-1):
      result[j] = result[i] + (j - i)
    yield result

iterator combinations*[T](itms: seq[T], k: Natural): seq[T] =
  for indices in combinations(itms.len, k):
    yield indices.mapIt(itms[it])

export
  tables.contains,
  tables.hasKey,
  tables.keys, tables.values, tables.pairs,
  tables.`[]=`,
  tables.`[]`
