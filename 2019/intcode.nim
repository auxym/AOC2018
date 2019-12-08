import math, sequtils, deques

type
    ParameterMode = enum pmImmediate, pmPosition
    IntcodeStatus* = enum
        icsNotStarted
        icsRunning
        icsWaitingOnInput
        icsHalted
    Instruction = tuple
        opcode: int8
        paramModes: array[4, ParameterMode]
    IntcodeProcess* = ref object
        memory: seq[int]
        ip: int
        stdin*: Deque[int]
        stdout*: Deque[int]
        status: IntcodeStatus

func initIntCode*(program: seq[int]): IntcodeProcess =
    new result
    result.memory = program
    result.stdin = initDeque[int](16)
    result.stdout = initDeque[int](16)
    result.status = icsNotStarted
    result.ip = 0

proc write*(p: IntcodeProcess, val: int) = p.stdin.addLast val
proc read*(p: IntcodeProcess) : int = p.stdout.popFirst

func getStatus*(p: IntcodeProcess): IntcodeStatus = p.status

func parseInstruction(i: int): Instruction =
    result.opcode = (i mod 100).int8
    let prmint = i div 100
    for i in 0..3:
        result.paramModes[i] =
            if (prmint div 10^i) mod 10 > 0:
                pmImmediate
            else:
                pmPosition

func getParams(code: seq[int], ip: int, num: Natural,
    pmodes: openArray[ParameterMode]): array[4, int] =
    for i in 0..<num:
        case pmodes[i]:
        of pmImmediate:
            result[i] = code[ip + 1 + i]
        of pmPosition:
            result[i] = code[code[ip + 1 + i]]

proc execute*(process: var IntcodeProcess) =
    process.status = icsRunning
    while process.status == icsRunning:
        var (opcode, pmodes) = parseInstruction(process.memory[process.ip])
        case opcode:
        of 1:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            process.memory[params[2]] = params[0] + params[1]
            process.ip.inc 4
        of 2:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            process.memory[params[2]] = params[0] * params[1]
            process.ip.inc 4
        of 3:
            if process.stdin.len < 1:
                process.status = icsWaitingOnInput
                continue
            let iout = process.memory[process.ip+1]
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
            if params[0] != 0: process.ip = params[1] else: process.ip.inc 3
        of 6:
            let params = getParams(process.memory, process.ip, 2, pmodes)
            if params[0] == 0: process.ip = params[1] else: process.ip.inc 3
        of 7:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            process.memory[params[2]] = if params[0] < params[1]: 1 else: 0
            process.ip.inc 4
        of 8:
            pmodes[2] = pmImmediate
            let params = getParams(process.memory, process.ip, 3, pmodes)
            process.memory[params[2]] = if params[0] == params[1]: 1 else: 0
            process.ip.inc 4
        of 99:
            process.status = icsHalted
        else:
            raise newException(ValueError, "Invalid opcode " & $opcode)

func runAndGetOutput*(program: seq[int], inputData: seq[int]): seq[int] =
    var pcs = initIntCode(program)
    for e in inputData:
        pcs.stdin.addLast e
    pcs.execute
    result = toSeq(pcs.stdout)
