import strutils, strformat, sequtils

# This implements a rather rudimentary recursive descent parser based on the
# book "Crafting Interpreters".

type ExprKind = enum ekNumber, ekBinary

type Expr = ref object
  case kind: ExprKind
  of ekNumber:
    val: int
  of ekBinary:
    l, r: Expr
    op: char

type Parser = object
  text: string
  current: int

type Rule = proc(p: var Parser): Expr

func isAtEnd(p: Parser): bool = p.current > p.text.high
func previous(p: Parser): char = p.text[p.current - 1]
func peek(p: Parser): char = p.text[p.current]

func advance(p: var Parser): char =
  if not p.isAtEnd: inc p.current
  result = p.previous

func match(p: var Parser, tokens: set[char]): bool =
  if not p.isAtEnd and p.peek in tokens:
    discard p.advance
    return true
  return false

template createPrimaryRule(name: untyped, base: Rule) =
  func name(p: var Parser): Expr =
    if p.match({'0'..'9'}):
      return Expr(kind: ekNumber, val: parseInt($p.previous))

    elif p.match({'('}):
      result = p.base
      doAssert p.advance == ')'

template createBinaryRule(name: untyped, parent: Rule, opset: set[char]) =
  func name(p: var Parser): Expr =
    result = p.parent
    while p.match(opset):
      let
        opr = p.previous
        right = p.parent
      result = Expr(kind: ekBinary, op: opr, l: result, r: right)

func parseExpr(p: var Parser): Expr
createPrimaryRule(parsePrimary, parseExpr)
createBinaryRule(parseAddMul, parsePrimary, {'+', '*'})

func parseExpr(p: var Parser): Expr =
  result = p.parseAddMul

func parse(text: string, base: Rule): Expr =
  var prs: Parser
  prs.current = 0
  # Note: we don't need to do a lexing step, once we remove whitespace, then
  # every char is a token.
  prs.text = text.replace(" ", "")
  return base(prs)

func `$`(e: Expr): string =
  case e.kind:
    of ekNumber: $(e.val)
    of ekBinary: fmt("({e.l} {e.op} {e.r})")

func eval(e: Expr): int =
  result = case e.kind:
  of ekNumber:
    e.val
  of ekBinary:
    case e.op:
      of '+': e.l.eval + e.r.eval
      of '*': e.l.eval * e.r.eval
      else: -1 shl 60 # Error

func eval(s: string): int = s.parse(parseExpr).eval

let inputLines = readFile("./input/day18_input.txt").strip.splitLines

let pt1 = inputLines.map(eval).foldl(a+b)
echo pt1
doAssert pt1 == 75592527415659

# Part 2

func parseExpr2(p: var Parser): Expr
createPrimaryRule(parsePrimary2, parseExpr2)
createBinaryRule(parseAdd, parsePrimary2, {'+'})
createBinaryRule(parseMul, parseAdd, {'*'})

func parseExpr2(p: var Parser): Expr =
  result = p.parseMul

func eval2(s: string): int = s.parse(parseExpr2).eval
let pt2 = inputLines.map(eval2).foldl(a+b)
echo pt2
doAssert pt2 == 360029542265462
