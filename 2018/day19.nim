import strutils
import sequtils
import strscans, strformat
import math

type
    Instruction = tuple[op: OpCode, A, B, C: int]
    State = array[6, int]
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

const ZERO_STATE: State = [0, 0, 0, 0, 0, 0]

proc readInput(fname: string): (int, seq[Instruction]) =
    let input = readFile(fname).strip().splitLines()

    var ipreg: int
    doAssert scanf(input[0], "#ip $i",ipreg)

    var
        ins: Instruction
        program: seq[Instruction]

    for line in input[1..input.high]:
        let parts = line.split(' ')
        ins.op = parseEnum[OpCode](parts[0].toUpper())
        ins.A = parseInt(parts[1])
        ins.B = parseInt(parts[2])
        ins.C = parseInt(parts[3])
        program.add ins

    return (ipreg, program)

func toInt(b: bool): int =
    if b: result = 1

proc runIns(s: var State, ins: Instruction) =
    case ins.op:
        of ADDR:
            s[ins.C] = s[ins.A] + s[ins.B]
        of ADDI:
            s[ins.C] = s[ins.A] + ins.B
        of MULR:
            s[ins.C] = s[ins.A] * s[ins.B]
        of MULI:
            s[ins.C] = s[ins.A] * ins.B
        of BANR:
            s[ins.C] = s[ins.A] and s[ins.B]
        of BANI:
            s[ins.C] = s[ins.A] and ins.B
        of BORR:
            s[ins.C] = s[ins.A] or s[ins.B]
        of BORI:
            s[ins.C] = s[ins.A] or ins.B
        of SETR:
            s[ins.C] = s[ins.A]
        of SETI:
            s[ins.C] = ins.A
        of GTIR:
            s[ins.C] = toInt(ins.A > s[ins.B])
        of GTRI:
            s[ins.C] = toInt(s[ins.A] > ins.B)
        of GTRR:
            s[ins.C] = toInt(s[ins.A] > s[ins.B])
        of EQIR:
            s[ins.C] = toInt(ins.A == s[ins.B])
        of EQRI:
            s[ins.C] = toInt(s[ins.A] == ins.B)
        of EQRR:
            s[ins.C] = toInt(s[ins.A] == s[ins.B])

func runProgram(prog: seq[Instruction], ipreg: int, initial=ZERO_STATE): State =
    var
        ip = 0

    result = initial
    while ip <= prog.high and ip >= prog.low:
        result[ipreg] = ip
        runIns(result, prog[ip])
        ip = result[ipreg]
        inc ip

func sumOfFactors(n: int): int =
    let maxfac = n.toFloat().sqrt().floor().toInt()
    for i in 1..maxfac:
        if n mod i == 0:
            result += i
            result += (n div i)

func runpt2(prog: seq[Instruction], ipreg: int, initial=ZERO_STATE): State =
    var
        ip = 0
    result = initial
    while ip <= prog.high and ip >= prog.low:
        if ip == 3:
            result[0] = sumOfFactors(result[4])
            ip = 16
        else:
            result[ipreg] = ip
            runIns(result, prog[ip])
            ip = result[ipreg]
            inc ip

proc dbgProgram(prog: seq[Instruction], ipreg: int, initial=ZERO_STATE): State =
    var
        ip = 0
        ui, prev: string

    result = initial
    while ip <= prog.high and ip >= prog.low:
        ui = stdin.readLine()
        if ui == "":
            ui = prev
        else:
            prev = ui

        case ui:
            of "q":
                break
            of "s":
                result[ipreg] = ip
                let ins = prog[ip]
                runIns(result, ins)
                var os = fmt"{ip:d} {ins.op:s} {ins.A:d} {ins.B:d} {ins.C:d} : {result:s}"
                ip = result[ipreg]
                inc ip
                echo os


let (ipreg, program) = readInput("./day19_input.txt")

let pt1 = runProgram(program, ipreg)
echo pt1

let pt2_init = [1, 0, 0, 0, 0, 0]
echo runpt2(program, ipreg, pt2_init)