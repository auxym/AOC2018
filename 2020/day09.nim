import utils, options, sequtils

type intpair = tuple[a, b: int]

let data = readFile("./input/day09_input.txt").getInts

func find2sum(list: seq[int], sum: int): Option[intpair] =
  for (i, elem) in list.pairs:
    let restOfList = list[(i+1)..list.high]
    if (sum - elem) in restOfList:
      return (elem, (sum - elem)).some
  return none(intpair)

func findInvalidXmas(list: seq[int], preambleLen: int): Option[Natural] =
  for i in preambleLen .. list.high:
    let
      preStart = i - preambleLen
      invalidFound = find2sum(list[preStart..<i], list[i])
    if isNone(invalidFound):
      return some(i.Natural)
  return none(Natural)

# Part 1
let invalidIdx = data.findInvalidXmas(25)
doAssert invalidIdx.isSome and data[invalidIdx.get] == 36845998
let invalidVal = data[invalidIdx.get]
echo invalidVal

# Part 2
func findContiguousSum(list: seq[int], sum: int): seq[int] =
  for i in 0..(list.high - 1):
    var contNum: seq[int] = @[list[i],]
    for b in list[(i + 1) .. list.high]:
      contNum.add b
      let nsum = contNum.foldl(a+b)
      if nsum == sum:
        return contNum
      elif nsum > sum:
        break

let
  contSumNumbers = findContiguousSum(data, invalidVal)
  pt2res = contSumNumbers.min + contSumNumbers.max
doAssert pt2res == 4830226
echo pt2res