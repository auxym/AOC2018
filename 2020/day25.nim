const
  tfModulus = 20201227
  cardPk = 15113849
  doorPk = 4206373
  pkSubjectNumber = 7

func transform(subnum: int, n: Natural): int =
  result = 1
  for i in 0..<n:
    result = (result * subnum) mod tfModulus

func findLoopSize(pkey: int): Natural =
  result = 0
  var trialKey = 1
  while true:
    inc result
    trialKey = (trialKey * pkSubjectNumber) mod tfModulus
    if trialKey == pkey:
      return result

let cardLoopSize = findLoopSize cardPk
assert transform(pkSubjectNumber, cardLoopSize) == cardPk
echo cardLoopSize

let encKey = transform(doorPk, cardLoopSize)
echo encKey
