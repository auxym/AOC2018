import strutils, regex, utils, sequtils

# Ugh, this took forever and it's really confusing to follow the recursive logic,
# but it does work, even in the general case.

type RuleKind = enum rkLiteral, rkRefs

type Rule = ref object
  case kind: RuleKind
    of rkLiteral:
      c: char
    of rkRefs:
      groups: seq[seq[int]]

type Parser = object
  text: string
  rules: seq[Rule]

func parseRules(text: string): seq[Rule] =
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

func matchRule(p: Parser, ruleIdx: int, start: seq[int]): seq[int]

func matchSeq(p: Parser, ruleSeq: seq[int], at: int): seq[int] =
  result = p.matchRule(ruleSeq[0], @[at])
  if result.len > 0 and ruleSeq.len > 1:
    var newResult: seq[int]
    for pos in result:
      newResult.add matchSeq(p, ruleSeq[1..^1], pos)
    result = newResult

func matchRule(p: Parser, ruleIdx: int, start: seq[int]): seq[int] =
  let rl = p.rules[ruleIdx]
  var validEndPos: seq[int]
  for spos in start:
    case rl.kind:
    of rkLiteral:
      if spos <= p.text.high and p.text[spos] == rl.c:
        validEndPos.add (spos + 1)
    of rkRefs:
      for choice in rl.groups:
        validEndPos.add p.matchSeq(choice, spos)
  return validEndPos

func isValidMessage(msg: string, rules: seq[Rule]): bool =
  var prs = Parser(text: msg.strip, rules: rules)
  let matchResult = prs.matchRule(0, @[0])
  return matchResult.anyIt(it > msg.high)

let
  inputText = readfile("./input/day19_input.txt").strip
  msgRules = inputText.split("\n\n")[0].parseRules
  messageList = inputText.split("\n\n")[1].splitLines

let pt1 = messageList.countIt(it.isValidMessage(msgRules))
echo pt1
doAssert pt1 == 120

# Part 2
func modifyRulesPt2(r: seq[Rule]): seq[Rule] =
  result = r
  result[8] = Rule(kind: rkRefs, groups: @[@[42], @[42, 8]])
  result[11] = Rule(kind: rkRefs, groups: @[@[42, 31], @[42, 11, 31]])

let
  rulesPt2 = msgRules.modifyRulesPt2
  pt2 = messageList.countIt(it.isValidMessage(rulesPt2))
echo pt2
doAssert pt2 == 350
