import strutils, sequtils, regex, strformat

func getInts(s: string): seq[int] =
    let expint = re"-?\d+"
    result = s.findAndCaptureAll(expint).map(parseInt)

let input = readFile("./input/day02.txt").getInts

func execute(code: seq[int]): seq[int] =
    var 
        ip = 0
        state = code
    while true:
        let opcode = state[ip]
        #debugEcho &"cur: {cur} [{state[cur]}]"
        if opcode == 99: break
        let
            a = state[state[ip + 1]]
            b = state[state[ip + 2]]
            iout = state[ip + 3]
        #debugEcho &"op:{opcode}\ta:{a}\tb:{b}\tiout:{iout}"
        case opcode:
            of 1:
                state[iout] = a + b
            of 2:
                state[iout] = a * b
            else:
                raise newException(ValueError, "Invalid opcode " & $opcode)
        ip += 4

    result = state

#echo execute(@[1,0,0,0,99])
#echo execute(@[2,3,0,3,99])
#echo execute(@[2,4,4,5,99,0])
#echo execute(@[1,1,1,4,99,5,6,0,99])

# Part 1
var part1_in = input
part1_in[1] = 12
part1_in[2] = 2
let part1_out = execute(part1_in)
doAssert part1_out[0] == 6568671
echo part1_out[0]

# Part 2
func execNounVerb(code: seq[int], noun, verb: int): int =
    var init = code
    init[1] = noun
    init[2] = verb
    result = execute(init)[0]

block search:
    for noun in 0..99:
        for verb in 0..99:
            let r = input.execNounVerb(noun, verb)
            if r == 19690720:
                echo $noun & " " & $verb
                break search