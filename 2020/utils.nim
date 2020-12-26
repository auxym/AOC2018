import regex, sequtils, strutils, algorithm, tables, strformat
import terminal, sets

type
  Compass* = enum North, East, South, West
  Vector* = tuple[x, y: int]
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

func cw*(v: Vector): Vector = # Rotate 90 degrees clockwise
  (v.y, -v.x)

func ccw*(v: Vector): Vector = # Rotate 90 degrees counter-clockwise
  (-v.y, v.x)

func `+`*(a, b: Vector): Vector = (a.x + b.x, a.y + b.y)
func `*`*(u: int, v: Vector): Vector = (u * v.x, u * v.y)

func manhattan*(a, b: Vector): Natural =
  abs(b.x - a.x) + abs(b.y - a.y)

func toVector*(d: Compass): Vector =
  case d
  of North: (0, 1)
  of East: (1, 0)
  of West: (-1, 0)
  of South: (0, -1)

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

iterator product*(n, k: int): seq[int] =
  let hi = n - 1
  var
    cur: seq[int]
    j = 0
  for i in 0..<k: cur.add 0
  while true:
    yield cur

    j = cur.high
    while j >= 0 and cur[j] == hi:
      dec j
    if j < 0:
      break

    cur[j].inc
    for i in (j + 1)..cur.high:
      cur[i] = 0

iterator product*[T](itms: seq[T], repeat: Natural): seq[T] =
  for indices in product(itms.len, repeat):
    yield indices.mapIt(itms[it])

func toBitString*(a: SomeInteger, size = 64): string =
  let spec = fmt"0{size}b"
  formatValue(result, a, spec)

iterator chain*[T](sequences: openArray[seq[T]]): T =
  for s in sequences:
    for e in s: yield e

proc dEchoHl*(s: string, hlPos: set[int16]) =
  var hlState = false
  for i, c in s.pairs:
    if i.int16 in hlPos and not hlState:
      stdout.setForegroundColor(fgRed)
      hlState = true
    elif hlState and i.int16 notin hlPos:
      stdout.resetAttributes
      hlState = false
    stdout.write(c)
  stdout.resetAttributes
  stdout.write "\n"

func peek*[T](s: HashSet[T]): T =
  for e in s: return e

export
  tables.contains,
  tables.hasKey,
  tables.keys, tables.values, tables.pairs,
  tables.`[]=`,
  tables.`[]`
