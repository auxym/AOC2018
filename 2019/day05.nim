import math, utils, strformat

let program = readFile("./input/day05.txt").getInts

type
    ParameterMode = enum pmImmediate, pmPosition
    Instruction = tuple
        opcode: int8
        paramModes: array[4, ParameterMode]

func parseInstruction(i: int): Instruction =
    result.opcode = (i mod 100).int8
    let prmint = i div 100
    for i in 0..3:
        result.paramModes[i] =
            if (prmint div 10^i) mod 10 > 0:
                pmImmediate
            else:
                pmPosition

func getParams(code: seq[int], ip: int, num: Natural, pmodes: openArray[ParameterMode]): array[4, int] =
    for i in 0..<num:
        case pmodes[i]:
        of pmImmediate:
            result[i] = code[ip + 1 + i]
        of pmPosition:
            result[i] = code[code[ip + 1 + i]]

func execute(program: seq[int], input: seq[int]): seq[int] =
    var
        state = program
        inStack = input.reverse
        ip = 0
    result = @[]
    while state[ip] != 99:
        var (opcode, pmodes) = parseInstruction(state[ip])
        #debugEcho fmt"ip: {ip} instr: {instr}"
        case opcode:
            of 1:
                pmodes[2] = pmImmediate
                let params = getParams(state, ip, 3, pmodes)
                state[params[2]] = params[0] + params[1]
                ip.inc 4
            of 2:
                pmodes[2] = pmImmediate
                let params = getParams(state, ip, 3, pmodes)
                state[params[2]] = params[0] * params[1]
                ip.inc 4
            of 3:
                let iout = state[ip+1]
                #debugEcho "Read input to position " & $iout
                state[iout] = inStack.pop
                ip.inc 2
            of 4:
                let params = getParams(state, ip, 1, pmodes)
                result.add params[0]
                ip.inc 2
            of 5:
                let params = getParams(state, ip, 2, pmodes)
                if params[0] != 0: ip = params[1] else: ip.inc 3
            of 6:
                let params = getParams(state, ip, 2, pmodes)
                if params[0] == 0: ip = params[1] else: ip.inc 3
            of 7:
                pmodes[2] = pmImmediate
                let params = getParams(state, ip, 3, pmodes)
                state[params[2]] = if params[0] < params[1]: 1 else: 0
                ip.inc 4
            of 8:
                pmodes[2] = pmImmediate
                let params = getParams(state, ip, 3, pmodes)
                state[params[2]] = if params[0] == params[1]: 1 else: 0
                ip.inc 4
            else:
                raise newException(ValueError, "Invalid opcode " & $opcode)

let part1 = program.execute(@[1])
doAssert part1[^1] == 6745903
echo part1

let part2 = program.execute(@[5])
doAssert part2[0] == 9168267
echo part2