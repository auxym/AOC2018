
import utils, algorithm, sequtils

# Alternative solution to day 10 pt 2
# We split the full sequence in sub-sequences separated by jumps of 3:
# A = [x 3 y]. The number of arrangements N(A) is N(x)*N(y). Since x and
# y contain only jumps of 1 jolt, N(x) and N(y) are computed by the tribonacci
# sequence.

func steps(a: seq[int]): seq[int] =
  result = newSeqOfCap[int](a.len - 1)
  for i in 1..a.high:
    result.add a[i] - a[i - 1]

func tribonacci(i: Natural): Natural =
  var prev = @[0, 1, 1]
  if i <= 2:
    return prev[i]
  for j in 3..i:
    result = prev.foldl(a+b)
    prev[0..1] = prev[1..2]
    prev[2] = result

iterator split[T](a: seq[T], sep: T): seq[T] =
  var result: seq[T] = @[]
  for elem in a:
    if elem == sep:
      if result.len > 0: yield result
      result = @[]
    else:
      result.add elem
  if result.len > 0: yield result

func countValidArrangements(adapters: seq[int]): int =
  let adapters = @[0] & adapters
  toSeq(adapters.steps.split(3))
    .mapIt(tribonacci(it.len + 1))
    .foldl(a*b)

let adapterList = readFile("./input/day10_input.txt").getInts.sorted()
let pt2ans = countValidArrangements(adapterList)
doAssert pt2ans == 113387824750592
echo pt2ans