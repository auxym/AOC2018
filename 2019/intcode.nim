import math, deques, bigints, regex, sequtils
export bigints

const default_mem_size = 1 shl 16

type
    ParameterMode = enum pmImmediate, pmPosition
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

func initIntCode*(program: seq[BigInt], memsize: Natural = default_mem_size): IntcodeProcess =
    new result
    result.stdin = initDeque[BigInt](16)
    result.stdout = initDeque[BigInt](16)
    result.status = icsNotStarted
    result.ip = 0

    result.memory = newSeq[BigInt](default_mem_size)
    for i, e in program:
        result.memory[i] = e

func parseBigIntDecimal(s: string): BigInt =
    initBigInt(s, 10)

proc readIntCodeProgram*(fname: string): seq[BigInt] =
    const expint = re"-?\d+"
    result = fname.readFile.findAndCaptureAll(expint).map(parseBigIntDecimal)

proc toInt64*(a: BigInt): int64 =
    doAssert a >= 0
    doAssert a <= initBigInt(int64.high)
    result = a.limbs[0].int64
    if a.limbs.len > 1:
        result = result or (a.limbs[1].int64 shl 32)
    doAssert initBigInt(result) == a

proc write*(p: IntcodeProcess, val: BigInt) = p.stdin.addLast val
proc read*(p: IntcodeProcess) : BigInt = p.stdout.popFirst

func getStatus*(p: IntcodeProcess): IntcodeStatus = p.status

func parseInstruction(instr: BigInt): Instruction =
    result.opcode = uint8((instr mod 100).limbs[0] and uint8.high.uint32)
    var prmint = instr div 100
    for i in 0..3:
        result.paramModes[i] =
            if prmint mod 10 > 0:
                pmImmediate
            else:
                pmPosition
        prmint = prmint div 10

func getParams(code: seq[BigInt], ip: int64, num: Natural,
    pmodes: openArray[ParameterMode]): array[4, BigInt] =
    for i in 0..<num:
        case pmodes[i]:
        of pmImmediate:
            result[i] = code[ip + 1 + i]
        of pmPosition:
            let idx = code[ip + 1 + i].toInt64
            result[i] = code[idx]

const bigOne = initBigInt(1'i8)
const bigZero = initBigInt(0'i8)

proc execute*(process: var IntcodeProcess) =
    process.status = icsRunning
    while process.status == icsRunning:
        var (opcode, pmodes) = parseInstruction(process.memory[process.ip])
        case opcode:
        of 1:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            let opres = params[0] + params[1]
            process.memory[params[2].toInt64] = opres
            process.ip.inc 4
        of 2:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            let opres = params[0] * params[1]
            process.memory[params[2].toInt64] = opres
            process.ip.inc 4
        of 3:
            if process.stdin.len < 1:
                process.status = icsWaitingOnInput
                continue
            let iout = process.memory[process.ip+1].toInt64
            process.memory[iout] = process.stdin.popFirst
            #debugEcho "Read input " & $process.memory[iout] & " to mem " & $iout
            process.ip.inc 2
        of 4:
            let params = getParams(process.memory, process.ip, 1, pmodes)
            #debugEcho "Write output: " & $params[0]
            process.stdout.addLast params[0]
            process.ip.inc 2
        of 5:
            let params = getParams(process.memory, process.ip, 2, pmodes)
            if params[0] != 0: process.ip = params[1].toInt64 else: process.ip.inc 3
        of 6:
            let params = getParams(process.memory, process.ip, 2, pmodes)
            if params[0] == 0: process.ip = params[1].toInt64 else: process.ip.inc 3
        of 7:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            process.memory[params[2].toInt64] = if params[0] < params[1]: bigOne else: bigZero
            process.ip.inc 4
        of 8:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            process.memory[params[2].toInt64] = if params[0] == params[1]: bigOne else: bigZero
            process.ip.inc 4
        of 99:
            process.status = icsHalted
        else:
            raise newException(ValueError, "Invalid opcode " & $opcode)

func runAndGetOutput*(program: seq[BigInt], inputData: seq[BigInt]): seq[BigInt] =
    var pcs = initIntCode(program)
    for e in inputData:
        pcs.stdin.addLast e
    pcs.execute
    result = toSeq(pcs.stdout)

func runAndGetOutput*(program: seq[BigInt], inputData: seq[int]): seq[BigInt] =
    let bigid = inputData.mapIt(it.initBigInt)
    result = program.runAndGetOutput(bigid)