import regex, strutils, sequtils, tables, utils

type Memory = Table[uint64, uint64]
type DockEmu = object
  mem: Memory
  mask: string

type WriteInstruction = tuple[addrs, val: uint64]

func setbit(n: uint64, i: int): uint64 =
  result = n or (1'u shl i)

func clearbit(n: uint64, i: int): uint64 =
  result = n and (not (1'u shl i))

func getMask(line: string): string =
  line.findAndCaptureAll(re"[01X]{36}")[0]

func apply(mask: string, n: uint64): uint64 =
  result = n
  let mh = mask.high
  for (i, c) in mask.pairs:
    case c
      of '0': result = result.clearbit(mh - i)
      of '1': result = result.setbit(mh - i)
      else: discard

# Test cases for masking
block:
  let tm = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"
  assert tm.apply(11) == 73
  assert tm.apply(101) == 101
  assert tm.apply(0) == 64

func parseWrite(line: string): WriteInstruction =
  var m: RegexMatch
  doAssert line.match(re"mem\[(\d+)\] = (\d+)", m)
  let
    maddr = m.group(0, line)[0].parseBiggestUInt
    mval = m.group(1, line)[0].parseBiggestUInt
  (maddr, mval)

proc write(em: var DockEmu, instr: string) =
  let (addrs, baseVal) = instr.parseWrite
  em.mem[addrs] = em.mask.apply(baseVal)

proc execute(em: var DockEmu, prog: seq[string]) =
  for line in prog:
    if line.startsWith("mask"):
      em.mask = line.getMask
    elif line.startsWith("mem"):
      em.write(line)
    else:
      raise newException(ValueError, "Bad line in program: " & line)

let program = readFile("./input/day14_input.txt").strip.splitLines

# Part 1

var dockComp: DockEmu
dockComp.execute(program)

let pt1 = toSeq(dockComp.mem.values).foldl(a+b)
echo pt1
doAssert pt1 == 9615006043476'u

# Part 2

type DockEmuV2 = distinct DockEmu

iterator applyMaskV2(mask: string, address: uint64): uint64 =
  var
    floating: seq[int]
    result = address
  let mh = mask.high
  for (i, c) in mask.pairs:
    case c
    of '1':
      result = result.setbit(mh - i)
    of 'X':
      floating.add i
    else: discard

  for floatvals in product(2, floating.len):
    for (i, bitval) in zip(floating, floatvals):
      case bitVal
      of 1:
        result = result.setbit(mh - i)
      of 0:
        result = result.clearbit(mh - i)
      else: discard
    yield result

proc writeV2(em: var DockEmu, instr: string) =
  let (baseAddr, val) = instr.parseWrite
  for maskedAddr in em.mask.applyMaskV2(baseAddr):
    em.mem[maskedAddr] = val

proc executeV2(em: var DockEmu, prog: seq[string]) =
  for line in prog:
    if line.startsWith("mask"):
      em.mask = line.getMask
    elif line.startsWith("mem"):
      em.writev2(line)
    else:
      raise newException(ValueError, "Bad line in program: " & line)

var dockComp2: DockEmu
dockComp2.executeV2(program)
let pt2 = toSeq(dockComp2.mem.values).foldl(a+b)
echo pt2
doAssert pt2 == 4275496544925'u