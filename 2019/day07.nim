import intcode, utils, intsets

type AmpPhase = range[0'i8..4'i8]

iterator rangeProduct[I: static Positive, T: range](): array[I, T] {.closure.} =
    var s: array[I, T]
    block outer:
        while true:
            yield s
            var i = s.high
            while s[i] == T.high:
                s[i] = T.low
                if i == 0: break outer
                i.dec
            s[i].inc

func hasNoDuplicate(s: array[5, AmpPhase]): bool =
    result = true
    var st = initIntSet()
    for elem in s:
        if elem in st: return false
        st.incl elem.int

iterator filteriter[T](iter: iterator(): T {.closure.}, pred: proc(a: T): bool): T =
    for x in iter(): 
        if pred(x):
            yield x

func runAmplifiers(ampProg: seq[int], phase: array[5, AmpPhase]): int =
    result = 0
    for i in 0..4:
        result = ampProg.runAndGetOutput(@[phase[i].int, result])[0]

let program = readFile("./input/day07.txt").getInts

var highSig: tuple[val: int, phase: array[5, AmpPhase]]
for phase in filteriter(rangeProduct[5, AmpPhase], hasNoDuplicate):
    let sig = runAmplifiers(program, phase)
    if sig > highSig.val: highSig = (sig, phase)
echo highSig
