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

let program = readFile("./input/day07.txt").getInts
const numAmps = 5

func runAmplifiers(ampProg: seq[int], phase: seq[int]): int =
    result = 0
    for i in 0..<numAmps:
        result = ampProg.runAndGetOutput(@[phase[i], result])[0]

var highSig: tuple[val: int, phase: seq[int]]
for phase in permutations(0, 4):
    let sig = runAmplifiers(program, phase)
    if sig > highSig.val: highSig = (sig, phase)
echo highSig
doAssert highSig.val == 440880

# Part 2

func runFeedback(ampProg: seq[int], phase: seq[int]): int =
    var
        amps: array[numAmps, IntcodeProcess]
        prevOutput: array[numAmps, int]

    for i in 0..<numAmps:
        amps[i] = initIntcode(ampProg)
        amps[i].write phase[i]

    amps[0].write 0

    var i = 0
    while amps[i].getStatus != icsHalted:
        amps[i].execute
        let cout = amps[i].read
        let nextAmp = (i + 1) mod numAmps
        amps[nextAmp].write cout
        prevOutput[i] = cout
        i = nextAmp

    return prevOutput[^1]

var highSigfb = int.low
for phase in permutations(5, 9):
    let outsig = runFeedback(program, phase)
    if outsig > highSigfb: highSigfb = outsig
echo highSigfb
doAssert highSigfb == 3745599