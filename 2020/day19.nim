import strutils, regex, utils, sequtils

type RuleKind = enum rkLiteral, rkRefs

type Rule = ref object
  case kind: RuleKind
    of rkLiteral:
      c: char
    of rkRefs:
      groups: seq[seq[int]]

type RuleGraph = seq[Rule]

type Parser = object
  current: int
  text: string
  rules: RuleGraph

func parseRules(text: string): RuleGraph =
  result = newSeq[Rule](256)
  let pat_lit = "\"([ab])\"".re

  for line in text.strip.splitLines:
    let
      parts = line.split(": ")
      idx = parts[0].strip.parseInt

    var m: RegexMatch
    let ex = parts[1].strip
    if ex.match(pat_lit, m):
      let lit: char = m.group(0, ex)[0][0]
      result[idx] = Rule(kind: rkLiteral, c: lit)
    else:
      assert ex.match(re"(\d+( |$))+(\|( \d+)+)?")
      let choices = ex.split("|").map(getInts)
      result[idx] = Rule(kind: rkRefs, groups: choices)

func `$`(r: Rule): string =
  case r.kind:
  of rkLiteral:
    "\"" & $r.c & "\""
  of rkRefs:
    "(" & r.groups.mapIt(it.join(" ")).join(" | ") & ")"

func isAtEnd(p: Parser): bool = p.current > p.text.high
func previous(p: Parser): char = p.text[p.current - 1]
func peek(p: Parser): char = p.text[p.current]

func advance(p: var Parser): char =
  if not p.isAtEnd: inc p.current
  result = p.previous

func matchChar(p: var Parser, ch: char): bool =
  if not p.isAtEnd and p.peek == ch:
    discard p.advance
    return true
  return false

proc matchRule(p: var Parser, ruleIdx: int): bool

proc matchSeq(p: var Parser, s: seq[int]): bool =
  let start = p.current
  for i in s:
    if not p.matchRule(i):
      p.current = start
      return false
  return true

proc matchChoice(p: var Parser, choices: seq[seq[int]]): bool =
  let start = p.current
  for chc in choices:
    if p.matchSeq(chc):
      return true
    p.current = start
  return false

proc matchRule(p: var Parser, ruleIdx: int): bool =
  let rl = p.rules[ruleIdx]
  result = case rl.kind:
  of rkLiteral:
    p.matchChar(rl.c)
  of rkRefs:
    p.matchChoice(rl.groups)

proc isValidMessage(msg: string, rules: RuleGraph): bool =
  var prs = Parser(current: 0, text: msg.strip, rules: rules)
  result = prs.matchRule(0) and prs.isAtEnd

when true:
  let testRules = """
  0: 4 1 5
  1: 2 3 | 3 2
  2: 4 4 | 5 5
  3: 4 5 | 5 4
  4: "a"
  5: "b"
  """.parseRules

  assert "ababbb".isValidMessage(testRules)
  assert "abbbab".isValidMessage(testRules)
  assert not "aaabbb".isValidMessage(testRules)
  assert not "bababa".isValidMessage(testRules)
  assert not "aaaabbb".isValidMessage(testRules)

when true:
  let
    inputText = readfile("./input/day19_input.txt").strip
    msgRules = inputText.split("\n\n")[0].parseRules
    messageList = inputText.split("\n\n")[1].splitLines

  var pt1 = 0
  for msg in messageList:
    if msg.isValidMessage(msgRules): inc pt1
  echo pt1
  doAssert pt1 == 120
