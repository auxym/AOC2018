import strscans
import strformat
import sequtils
import sets
import tables

type
    NumInstruction = tuple[op, A, B, C: int]
    Instruction = tuple[op: OpCode, A, B, C: int]
    State = array[4, int]
    Sample = tuple[before, after: State, ins: NumInstruction]
    OpCode = enum
        ADDR
        ADDI
        MULR
        MULI
        BANR
        BANI
        BORR
        BORI
        SETR
        SETI
        GTIR
        GTRI
        GTRR
        EQIR
        EQRI
        EQRR

proc readInput(fname: string): (seq[Sample], seq[NumInstruction]) =
    let f = open(fname)

    const
        stPat = "[$i, $i, $i, $i]"
        befPat = "Before: " & stPat
        aftPat = "After:  " & stPat
        inPat = "$i $i $i $i"

    var
        a, b, c, d: int
        smp: Sample

    while true:
        var threeLines: array[3, string]
        for i in 0..2:
            threeLines[i] = f.readLine()
            
        if threeLines[0] == "" and threeLines[1] == "":
            break

        discard f.readLine()


        doAssert scanf(threeLines[0], befPat, a, b, c, d)
        smp.before = [a, b, c, d]

        doAssert scanf(threeLines[1], inPat, a, b, c, d)
        smp.ins = (a, b, c, d)

        doAssert scanf(threeLines[2], aftPat, a, b, c, d)
        smp.after = [a, b, c, d]

        result[0].add smp

    while true:
        try:
            doAssert scanf(f.readline(), inPat, a, b, c, d)
        except EOFError:
            break
        result[1].add (a, b, c, d)

func runIns(s: State, ins: Instruction): State =
    result = s
    case ins.op:
        of ADDR:
            result[ins.C] = s[ins.A] + s[ins.B]
        of ADDI:
            result[ins.C] = s[ins.A] + ins.B
        of MULR:
            result[ins.C] = s[ins.A] * s[ins.B]
        of MULI:
            result[ins.C] = s[ins.A] * ins.B
        of BANR:
            result[ins.C] = s[ins.A] and s[ins.B]
        of BANI:
            result[ins.C] = s[ins.A] and ins.B
        of BORR:
            result[ins.C] = s[ins.A] or s[ins.B]
        of BORI:
            result[ins.C] = s[ins.A] or ins.B
        of SETR:
            result[ins.C] = s[ins.A]
        of SETI:
            result[ins.C] = ins.A
        of GTIR:
            if ins.A > s[ins.B]:
                result[ins.C] = 1
            else:
                result[ins.C] = 0
        of GTRI:
            if s[ins.A] > ins.B:
                result[ins.C] = 1
            else:
                result[ins.C] = 0
        of GTRR:
            if s[ins.A] > s[ins.B]:
                result[ins.C] = 1
            else:
                result[ins.C] = 0
        of EQIR:
            if ins.A == s[ins.B]:
                result[ins.C] = 1
            else:
                result[ins.C] = 0
        of EQRI:
            if s[ins.A] == ins.B:
                result[ins.C] = 1
            else:
                result[ins.C] = 0
        of EQRR:
            if s[ins.A] == s[ins.B]:
                result[ins.C] = 1
            else:
                result[ins.C] = 0

func runProgram(prog: seq[Instruction]): State =
    for i in prog:
        result = runIns(result, i)

func findCandidates(smp: Sample): HashSet[OpCode] =
    result = initSet[OpCode](8)
    for cand in OpCode:
        var ins: Instruction
        ins.op = cand
        ins.A = smp.ins.A
        ins.B = smp.ins.B
        ins.C = smp.ins.C
        if runIns(smp.before, ins) == smp.after:
            result.incl cand

func translate(a: NumInstruction, optable: TableRef[int, OpCode]): Instruction =
    result.op = optable[a.op]
    result.A = a.A
    result.B = a.B
    result.C = a.C

func inferOpCodeTable(samples: seq[Sample]): TableRef[int, OpCode] =
    var
        opcodenums = initSet[int](16)
        cndTab = initTable[int, HashSet[OpCode]](16)
        allOpCodes = initSet[OpCode](16)

    for code in OpCode: allOpCodes.incl code
    for smp in samples: opcodenums.incl(smp.ins.op)
    for num in opcodenums: cndTab[num] = allOpCodes

    for smp in samples:
        let candidates = findCandidates(smp)
        cndTab[smp.ins.op] = cndTab[smp.ins.op].intersection(candidates)

    result = newTable[int, OpCode](16)
    assert result.len == 0

    while result.len < 16:
        var
            foundFlag = false
            foundPair: tuple[num: int, code: OpCode]

        for k, v in cndTab:
            if v.len == 1:
                foundFlag = true
                foundPair = (k, toSeq(v.items)[0])
                break

        if not foundFlag:
            for code in allOpCodes:
                let cnums = opcodenums.filterIt(cndTab[it].contains(code))
                if cnums.len == 1:
                    foundFlag = true
                    foundPair = (cnums[0], code)
                    break

        if not foundFlag:
            break

        result[foundPair.num] = foundPair.code
        for k in cndTab.keys:
            cndTab[k].excl foundPair.code

    assert result.len == 16


let (samples, program) = readInput("day16_input.txt")

# Part 1
echo samples.map(findCandidates).filterIt(it.len >= 3).len

# Part 2
let optab = inferOpCodeTable(samples)
let progResult = program.mapIt(it.translate(optab)).runProgram()
echo progResult