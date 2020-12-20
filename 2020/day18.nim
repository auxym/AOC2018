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

const digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

func isAtEnd(p: Parser): bool = p.current > p.text.high
func previous(p: Parser): char = p.text[p.current - 1]
func peek(p: Parser): char = p.text[p.current]

func advance(p: var Parser): char =
  if p.current <= p.text.high: inc p.current
  result = p.previous

func match(p: var Parser, tokens: set[char]): bool =
  if not p.isAtEnd and p.peek in tokens:
    discard p.advance
    return true
  return false

func parseExpr(p: var Parser): Expr

func parsePrimary(p: var Parser): Expr =
  if p.match(digits):
    return Expr(kind: ekNumber, val: parseInt($p.previous))

  elif p.match({'('}):
    result = p.parseExpr
    doAssert p.advance == ')'

func parseAddMul(p: var Parser): Expr =
  result = p.parsePrimary
  while p.match({'+', '*'}):
    let
      operator = p.previous
      right = p.parsePrimary
    result = Expr(kind: ekBinary, l: result, r: right, op: operator)

func parseExpr(p: var Parser): Expr =
  result = p.parseAddMul

func parse(text: string): Expr =
  var prs: Parser
  prs.current = 0
  # Note: we don't need to do a lexing step, once we remove whitespace, then
  # every char is a token.
  prs.text = text.replace(" ", "")
  return prs.parseExpr

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
      else: -1 shl 60

func eval(s: string): int = s.parse.eval

let inputLines = readFile("./input/day18_input.txt").strip.splitLines

let pt1 = inputLines.map(eval).foldl(a+b)
echo pt1
doAssert pt1 == 75592527415659