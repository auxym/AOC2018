import math, deques, bigints, regex, sequtils, strformat
export bigints

const default_mem_size = 1 shl 12

type
    ParameterMode = enum pmImmediate, pmPosition, pmRelative
    IntcodeStatus* = enum
        icsNotStarted
        icsRunning
        icsWaitingOnInput
        icsHalted
    Instruction = tuple
        opcode: uint8
        paramModes: array[4, ParameterMode]
    IntcodeProcess* = ref object
        memory: seq[BigInt]
        ip: int64
        stdin*: Deque[BigInt]
        stdout*: Deque[BigInt]
        status: IntcodeStatus
        relbase: int64

func getBigInts*(s: string): seq[BigInt] =
    func parseBigIntDecimal(s: string): BigInt =
        initBigInt(s, 10)
    const expint = re"-?\d+"
    s.findAndCaptureAll(expint).map(parseBigIntDecimal)

proc readIntCodeProgram*(fname: string): seq[BigInt] =
    result = fname.readFile.getBigInts

func initIntCode*(program: seq[BigInt], memsize: Natural = default_mem_size): IntcodeProcess =
    new result
    result.stdin = initDeque[BigInt](16)
    result.stdout = initDeque[BigInt](16)
    result.status = icsNotStarted
    result.ip = 0
    result.relbase = 0

    result.memory = newSeq[BigInt](default_mem_size)
    for i, e in program:
        result.memory[i] = e

proc toInt64*(a: BigInt): int64 =
    doAssert a <= initBigInt(int64.high)
    doAssert a >= initBigInt(int64.low)
    result = a.limbs[0].int64
    if a.limbs.len > 1:
        result = result or (a.limbs[1].int64 shl 32)
    if a < 0:
        result = not result + 1
    doAssert initBigInt(result) == a

proc write*(p: IntcodeProcess, val: BigInt) = p.stdin.addLast val
proc read*(p: IntcodeProcess) : BigInt = p.stdout.popFirst

func getStatus*(p: IntcodeProcess): IntcodeStatus = p.status

func parseInstruction(instr: BigInt): Instruction =
    result.opcode = uint8((instr mod 100).limbs[0] and uint8.high.uint32)
    var prmint = (instr div 100).toInt64
    for i in 0..3:
        result.paramModes[i] = case (prmint mod 10):
            of 0: pmPosition
            of 1: pmImmediate
            of 2: pmRelative
            else: raise newException(ValueError, "Invalid param mode " & $prmint)
        prmint = prmint div 10

func readRelIp(prc: IntcodeProcess, offset: int64): BigInt =
    prc.memory[prc.ip + offset]

func readParams(prc: IntcodeProcess, num: Natural,
                pmodes: openArray[ParameterMode]): seq[BigInt] =
    result = @[]
    for i in 0..<num:
        case pmodes[i]:
        of pmImmediate:
            result.add prc.readRelIp(i + 1)
        of pmPosition:
            let idx = prc.readRelIp(1 + i).toInt64
            result.add prc.memory[idx]
        of pmRelative:
            let idx = prc.readRelIp(1 + i).toInt64 + prc.relbase
            result.add prc.memory[idx]

proc setmem(prc: var IntcodeProcess, where: BigInt,  mode: ParameterMode, val: BigInt) =
    var iout = where.toInt64
    if mode == pmRelative:
        iout += prc.relbase
    prc.memory[iout] = val

const bigOne = initBigInt(1'i8)
const bigZero = initBigInt(0'i8)

proc execute*(process: var IntcodeProcess) =
    process.status = icsRunning
    while process.status == icsRunning:
        let
            instr = process.memory[process.ip]
            (opcode, pmodes) = parseInstruction(instr)
        #var msg = fmt"ip: {process.ip} instr: {instr} opcode: {opcode} Param Modes: {pmodes}"
        case opcode:
        of 1:
            let params = process.readParams(2, pmodes)
            let opres = params[0] + params[1]
            process.setmem(process.readRelIp(3), pmodes[2], opres)
            process.ip.inc 4
        of 2:
            let params = process.readParams(2, pmodes)
            let opres = params[0] * params[1]
            process.setmem(process.readRelIp(3), pmodes[2], opres)
            process.ip.inc 4
        of 3:
            if process.stdin.len < 1:
                process.status = icsWaitingOnInput
                continue
            let iout = process.readRelIp(1)
            process.setmem(iout, pmodes[0], process.stdin.popFirst)
            process.ip.inc 2
        of 4:
            let params = process.readParams(1, pmodes)
            process.stdout.addLast params[0]
            process.ip.inc 2
        of 5:
            let params = process.readParams(2, pmodes)
            if params[0] != 0: process.ip = params[1].toInt64 else: process.ip.inc 3
        of 6:
            let params = process.readParams(2, pmodes)
            if params[0] == 0: process.ip = params[1].toInt64 else: process.ip.inc 3
        of 7:
            let params = process.readParams(2, pmodes)
            let opres = if params[0] < params[1]: bigOne else: bigZero
            process.setmem(process.readRelIp(3), pmodes[2], opres)
            process.ip.inc 4
        of 8:
            let params = process.readParams(3, pmodes)
            let opres = if params[0] == params[1]: bigOne else: bigZero
            process.setmem(process.readRelIp(3), pmodes[2], opres)
            process.ip.inc 4
        of 9:
            let params = process.readParams(1, pmodes)
            process.relbase += params[0].toInt64
            process.ip.inc 2
        of 99:
            process.status = icsHalted
        else:
            raise newException(ValueError, "Invalid opcode " & $opcode)
        #debugEcho msg

func runAndGetOutput*(program: seq[BigInt], inputData: seq[BigInt]): seq[BigInt] =
    var pcs = initIntCode(program)
    for e in inputData:
        pcs.stdin.addLast e
    pcs.execute
    doAssert pcs.status == icsHalted
    result = toSeq(pcs.stdout)

func runAndGetOutput*(program: seq[BigInt], inputData: seq[int]): seq[BigInt] =
    let bigid = inputData.mapIt(it.initBigInt)
    result = program.runAndGetOutput(bigid)