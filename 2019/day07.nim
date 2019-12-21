import intcode, utils, algorithm

iterator permutations[T: SomeInteger](a, b: T): seq[T] =
    var
        x = newSeqOfCap[T](b - a + 1)
        hasNew = true
    for i in a..b:
        x.add i
    while hasNew:
        yield x
        hasNew = x.nextPermutation

# Part 1

let program = readIntCodeProgram("./input/day07.txt")
const numAmps = 5

func runAmplifiers(ampProg: seq[BigInt], phase: seq[int]): BigInt =
    result = 0.initBigInt
    for i in 0..<numAmps:
        result = ampProg.runAndGetOutput(@[phase[i].initBigInt, result])[0]

var highSig: tuple[val: int64, phase: seq[int]]
for phase in permutations(0, 4):
    let sig = runAmplifiers(program, phase).toInt64
    if sig > highSig.val: highSig = (sig, phase)
echo highSig
doAssert highSig.val == 440880

# Part 2

func runFeedback(ampProg: seq[BigInt], phase: seq[int]): BigInt =
    var
        amps: array[numAmps, IntcodeProcess]
        prevOutput: array[numAmps, BigInt]

    for i in 0..<numAmps:
        amps[i] = initIntcode(ampProg)
        amps[i].write phase[i].initBigInt

    amps[0].write 0.initBigInt

    var i = 0
    while amps[i].getStatus != icsHalted:
        amps[i].execute
        let cout = amps[i].read
        let nextAmp = (i + 1) mod numAmps
        amps[nextAmp].write cout
        prevOutput[i] = cout
        i = nextAmp

    return prevOutput[^1]

var highSigfb = int64.low
for phase in permutations(5, 9):
    let outsig = runFeedback(program, phase).toInt64
    if outsig > highSigfb: highSigfb = outsig
echo highSigfb
doAssert highSigfb == 3745599