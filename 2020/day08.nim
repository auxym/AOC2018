import strutils, regex, strformat, intsets

type OpCode = enum opJmp, opAcc, opNop

type Instruction = tuple
  op: OpCode
  val: int

type Handheld = object
  program: seq[Instruction]
  acc: int
  ip: Natural

func initHandheld(program: seq[Instruction]): Handheld =
  result.program = program
  result.acc = 0
  result.ip = 0

func executionFinished(h: Handheld): bool =
  h.ip > h.program.high

proc runOne(h: var Handheld): bool =
  if h.executionFinished:
    return false
  let ins = h.program[h.ip]
  #echo fmt"ip: {h.ip} op: {ins.op} val: {ins.val}"
  case ins.op:
    of opJmp: inc(h.ip, ins.val)
    of opNop: inc h.ip
    of opAcc:
      inc(h.acc, ins.val)
      inc h.ip
  return true

func parseOpcode(s: string): OpCode =
  case s:
    of "nop": opNop
    of "acc": opAcc
    of "jmp": opJmp
    else: raise newException(ValueError, fmt"Unknown op '{s}'")

func parseProgram(text: string): seq[Instruction] =
  var m: RegexMatch
  for line in text.strip.splitLines:
    doAssert line.match(re"([a-z]{3}) ((?:\+|-)\d+)", m)
    let
      op = parseOpcode(m.group(0, line)[0])
      v = parseInt(m.group(1, line)[0])
    result.add (op, v)

let program = readFile("./input/day08_input.txt").parseProgram
var
  handh = initHandheld(program)
  seen = initIntSet()

# Part 1
while handh.ip notin seen:
  seen.incl handh.ip
  discard handh.runOne
let pt1 = handh.acc
echo pt1
doAssert pt1 == 1384

# Part 2
proc runUntilFinishedOrRepeat(h: var Handheld) =
  var seen = initIntSet()
  while not (h.executionFinished or h.ip in seen):
    seen.incl h.ip
    discard h.runOne

var pt2 = 0
for (i, pgmIns) in program.pairs:
  # Create modified program
  var modProgram = program
  case pgmIns.op:
    of opNop: modProgram[i] = (opJmp, pgmIns.val)
    of opJmp: modProgram[i] = (opNop, pgmIns.val)
    else: discard
  assert program[i] == pgmIns # We didn't modify the original program

  var hh = initHandheld(modProgram)
  hh.runUntilFinishedOrRepeat()
  if hh.executionFinished:
    pt2 = hh.acc
    echo pt2
    break

doAssert pt2 == 761